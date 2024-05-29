resource "aws_autoscaling_group" "asg" {
  name_prefix               = "${var.name}-vault-${var.consul_datacenter}"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = "${var.instance_count}"
  
  instance_refresh {
    strategy               = "Rolling"
    preferences {
      min_healthy_percentage = 0  
    }
  }
  launch_template {
    id = aws_launch_template.lt.id
  }
  
  target_group_arns         = var.target_groups
  vpc_zone_identifier       = var.private_subnets

  tag {
    key                 = "Name"
    value               = "${var.name}-${var.consul_datacenter}"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "lt" {
  instance_type = "t3.small"
  image_id = data.aws_ami.ubuntu.id

  iam_instance_profile {
    name = aws_iam_instance_profile.profile.name
  }
  name_prefix = "${var.name}-vault-${var.consul_datacenter}"
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.name}-${var.consul_datacenter}",
      role = "${var.name}-${var.consul_datacenter}",
    }
  }  
  update_default_version = true

  user_data = base64encode(templatefile("${path.module}/templates/userdata.sh.tftpl", { 
    name                  = var.name,
    service_tags          = jsonencode(var.service_tags),
    message               = local.message,
    vault_binary          = var.vault_binary,
    vault_version         = var.vault_version,
    consul_datacenter     = var.consul_datacenter, 
    consul_partition      = var.consul_partition,
    consul_version        = var.consul_version,
    consul_token          = var.consul_token,
    consul_encryption_key = var.consul_encryption_key,
    consul_license        = var.consul_license,
    consul_agent_ca       = var.consul_agent_ca,
    consul_binary         = var.consul_binary,
    consul_namespace      = var.consul_namespace,
    consul_agent_token    = var.consul_agent_token,
    instance_count        = var.instance_count,
    upstream_uris         = var.upstream_uris,
    app_port              = var.app_port,
    target_groups         = var.target_groups,
  }))
  vpc_security_group_ids = [aws_security_group.sg.id]
}

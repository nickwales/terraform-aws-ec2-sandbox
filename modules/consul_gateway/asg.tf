resource "aws_autoscaling_group" "consul_gateway" {
  name                      = "consul-gateway-${var.datacenter}"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = "${var.consul_gateway_count}"
  launch_template {
    id = aws_launch_template.consul_gateway.id
  }
  
  target_group_arns         = var.target_groups
  vpc_zone_identifier       = var.private_subnets

  tag {
    key                 = "Name"
    value               = "consul-gateway-${var.datacenter}"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "consul_gateway" {
  instance_type = "t3.small"
  image_id = data.aws_ami.ubuntu.id

  iam_instance_profile {
    name = aws_iam_instance_profile.consul_gateway.name
  }
  name = "consul-gateway-${var.datacenter}"
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "consul-gatway-${var.datacenter}",
      role = "consul-gateway-${var.datacenter}",
    }
  }  
  update_default_version = true

  user_data = base64encode(templatefile("${path.module}/templates/userdata.sh.tftpl", { 
    datacenter            = var.datacenter, 
    consul_version        = var.consul_version,
    consul_token          = var.consul_token,
    consul_encryption_key = var.consul_encryption_key,
    consul_license        = var.consul_license,
    consul_server_count   = var.consul_gateway_count,
    consul_agent_ca       = var.consul_agent_ca,
    consul_binary         = var.consul_binary,
    consul_partition      = var.consul_partition,
    consul_namespace      = var.consul_namespace,    
  }))
  vpc_security_group_ids = [aws_security_group.consul_gateway_sg.id]
}

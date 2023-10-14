resource "aws_autoscaling_group" "consul_server" {
  name                      = "consul-server-${var.datacenter}"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = "${var.consul_server_count}"
  launch_template {
    id = aws_launch_template.consul_server.id
  }
  target_group_arns         = var.target_groups
  vpc_zone_identifier       = var.private_subnets

  tag {
    key                 = "Name"
    value               = "consul-server-${var.datacenter}"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "consul_server" {
  instance_type = "t3.small"
  image_id = data.aws_ami.ubuntu.id

  iam_instance_profile {
    name = aws_iam_instance_profile.consul_server.name
  }
  name = "consul-server-${var.datacenter}"
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "consul-server-${var.datacenter}",
      role = "consul-server-${var.datacenter}",
    }
  }  
  update_default_version = true

  user_data = base64encode(templatefile("${path.module}/templates/userdata.sh.tftpl", { 
    datacenter            = var.datacenter, 
    consul_version        = var.consul_version,
    consul_token          = var.consul_token,
    consul_encryption_key = var.consul_encryption_key,
    consul_license        = var.consul_license,
    consul_server_count   = var.consul_server_count,
    consul_server_key     = var.consul_server_key,
    consul_server_cert    = var.consul_server_cert,
    consul_agent_ca       = var.consul_agent_ca,
    consul_binary         = var.consul_binary,    
  }))
  vpc_security_group_ids = [aws_security_group.consul_server_sg.id]
}

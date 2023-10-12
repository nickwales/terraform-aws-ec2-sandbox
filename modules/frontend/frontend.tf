resource "aws_autoscaling_group" "frontend" {
  name                      = "frontend-${var.datacenter}"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = "${var.frontend_count}"
  launch_template {
    id = aws_launch_template.frontend.id
  }
  
  target_group_arns         = [aws_lb_target_group.frontend.arn]
  vpc_zone_identifier       = var.private_subnets

  tag {
    key                 = "Name"
    value               = "frontend-${var.datacenter}"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "frontend" {
  instance_type = "t3.small"
  image_id = data.aws_ami.ubuntu.id

  iam_instance_profile {
    name = aws_iam_instance_profile.frontend.name
  }
  name = "frontend-${var.datacenter}"
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "frontend-${var.datacenter}",
      role = "frontend-${var.datacenter}",
    }
  }  
  update_default_version = true

  user_data = base64encode(templatefile("${path.module}/templates/frontend.sh.tftpl", { 
    datacenter            = var.datacenter, 
    consul_version        = var.consul_version,
    consul_token          = var.consul_token,
    consul_encryption_key = var.consul_encryption_key,
    consul_license        = var.consul_license,
    consul_server_count   = var.frontend_count,
    consul_agent_ca       = var.consul_agent_ca,
    consul_binary         = var.consul_binary,
  }))
  vpc_security_group_ids = [aws_security_group.frontend.id]
}

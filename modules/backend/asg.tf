resource "aws_autoscaling_group" "backend" {
  name                      = "backend-${var.datacenter}"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = "${var.backend_count}"
  launch_template {
    id = aws_launch_template.backend.id
  }
  
  vpc_zone_identifier       = var.private_subnets

  tag {
    key                 = "Name"
    value               = "backend-${var.datacenter}"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "backend" {
  instance_type = "t3.small"
  image_id = data.aws_ami.ubuntu.id

  iam_instance_profile {
    name = aws_iam_instance_profile.backend.name
  }
  name = "backend-${var.datacenter}"
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "backend-${var.datacenter}",
      role = "backend-${var.datacenter}",
    }
  }  
  update_default_version = true

  user_data = base64encode(templatefile("${path.module}/templates/backend.sh.tftpl", { 
    datacenter            = var.datacenter, 
    partition             = var.partition,    
    consul_version        = var.consul_version,
    consul_token          = var.consul_token,
    consul_encryption_key = var.consul_encryption_key,
    consul_license        = var.consul_license,
    consul_server_count   = var.backend_count,
    consul_agent_ca       = var.consul_agent_ca,
    consul_binary         = var.consul_binary,
  }))
  vpc_security_group_ids = [aws_security_group.backend.id]
}

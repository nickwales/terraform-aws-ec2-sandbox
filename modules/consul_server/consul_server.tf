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
  target_group_arns         = [aws_lb_target_group.consul.arn]
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

  user_data = base64encode(templatefile("${path.module}/templates/consul_server.sh.tftpl", { 
    datacenter            = var.datacenter, 
    consul_version        = var.consul_version,
    consul_token          = var.consul_token,
    consul_encryption_key = var.consul_encryption_key,
    consul_license        = var.consul_license,
    consul_server_count   = var.consul_server_count,
    consul_server_key     = var.consul_server_key,
    consul_server_cert    = var.consul_server_cert,
    consul_agent_ca       = var.consul_agent_ca,

  }))
  vpc_security_group_ids = [aws_security_group.consul_server_sg.id]
  

}

# resource "aws_instance" "consul_server" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t3.small"
  
#   iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
#   vpc_security_group_ids = [aws_security_group.instance_security_group.id]
#   subnet_id              = module.vpc.private_subnets[0]  
  
#   associate_public_ip_address = true

#   tags = {
#     Name = var.name
#     Owner = var.owner
#     Purpose = var.purpose
#     se_region = var.region
#     role = "consul-server"
#   }

#   user_data = templatefile("${path.module}/templates/consul_server.sh.tftpl", { 
#     datacenter         = "dc1", 
#     consul_version        = var.consul_version,
#     consul_token          = var.consul_token,
#     consul_server_key     = data.local_file.consul_server_key.content,
#     consul_server_cert    = data.local_file.consul_server_cert.content,
#     consul_agent_ca       = data.local_file.consul_agent_ca.content,
#     consul_encryption_key = data.local_file.consul_encryption_key.content,
#     consul_license        = data.local_file.consul_encryption_license.content,
#   })
# }

# resource "aws_lb_target_group_attachment" "consul_server_ui" {
#   target_group_arn = aws_lb_target_group.consul.arn
#   target_id        = aws_instance.consul_server.id
#   port             = 8501
# }
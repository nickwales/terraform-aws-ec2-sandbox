module "consul_server_dc1" {
  source = "../../modules/consul_server"

  name  = var.name
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region

  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets

  consul_server_key   = data.local_file.consul_server_key_dc1.content
  consul_server_cert  = data.local_file.consul_server_cert_dc1.content
  consul_agent_ca     = data.local_file.consul_agent_ca_dc1.content
  
  consul_license = var.consul_license
  consul_binary  = var.consul_binary 
}

module "consul_gateway_dc1" {
  source = "../../modules/consul_gateway"

  name  = var.name
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region
  datacenter = "dc1"

  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets

  consul_agent_ca = data.local_file.consul_agent_ca_dc1.content
  
  consul_license = var.consul_license
  consul_binary  = var.consul_binary
}

module "consul_frontend_dc1" {
  source = "../../modules/frontend"

  name  = var.name
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region
  datacenter = "dc1"
  partition = var.dc1_frontend_partition

  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets

  consul_agent_ca = data.local_file.consul_agent_ca_dc1.content
  
  consul_license = var.consul_license
  consul_binary  = var.consul_binary  
}

module "consul_middleware_dc1" {
  source = "../../modules/middleware"

  name  = var.name
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region
  datacenter = "dc1"
  partition = var.dc1_middleware_partition

  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets

  consul_agent_ca = data.local_file.consul_agent_ca_dc1.content
  
  consul_license = var.consul_license
  consul_binary  = var.consul_binary  
}



# resource "aws_autoscaling_group" "consul_server" {
#   name                      = "consul-server-${var.datacenter}"
#   max_size                  = 3
#   min_size                  = 1
#   health_check_grace_period = 300
#   health_check_type         = "ELB"
#   desired_capacity          = "${var.consul_server_count}"
#   launch_template {
#     id = aws_launch_template.consul_server.id
#   }
#   target_group_arns         = [aws_lb_target_group.consul.arn]
#   vpc_zone_identifier       = module.vpc.private_subnets

#   tag {
#     key                 = "Name"
#     value               = "consul-server-${var.datacenter}"
#     propagate_at_launch = true
#   }
# }

# resource "aws_launch_template" "consul_server" {
#   instance_type = "t3.small"
#   image_id = data.aws_ami.ubuntu.id

#   iam_instance_profile {
#     name = aws_iam_instance_profile.instance_profile.name
#   }
#   name = "consul-server-${var.datacenter}"
#   tag_specifications {
#     resource_type = "instance"

#     tags = {
#       Name = "consul-server-${var.datacenter}",
#       role = "consul-server-${var.datacenter}",
#     }
#   }  
#   update_default_version = true

#   user_data = base64encode(templatefile("${path.module}/templates/consul_server.sh.tftpl", { 
#     datacenter            = var.datacenter, 
#     consul_version        = var.consul_version,
#     consul_token          = var.consul_token,
#     consul_encryption_key = var.consul_encryption_key,
#     consul_license        = var.consul_license,
#     consul_server_count   = var.consul_server_count,
#     consul_server_key     = data.local_file.consul_server_key.content,
#     consul_server_cert    = data.local_file.consul_server_cert.content,
#     consul_agent_ca       = data.local_file.consul_agent_ca.content,

#   }))
#   vpc_security_group_ids = [aws_security_group.instance_security_group.id]
  

# }

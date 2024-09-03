module "consul_server" {
  source  = "app.terraform.io/nickwales/aws-consul-server/module"
  version = "0.0.6"

  name  = var.name
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region

  private_subnets = module.vpc.private_subnets

  consul_server_key   = data.local_file.consul_server_key.content
  consul_server_cert  = data.local_file.consul_server_cert.content
  consul_agent_ca     = data.local_file.consul_agent_ca.content
  
  consul_encryption_key = var.consul_encryption_key
  
  consul_license = var.consul_license
  consul_binary  = var.consul_binary 

  target_groups = [aws_lb_target_group.consul.arn, aws_lb_target_group.consul_https.arn]
}



module "aws-fake-service" {
  source  = "app.terraform.io/nickwales/aws-fake-service/module"
  version = "0.0.4"
  
  vpc_id = module.vpc.vpc_id
  region = var.region

  private_subnets = module.vpc.private_subnets

  name  = var.name
  owner = var.owner
  fake_service_name = "test"
  fake_service_message = "message"

  consul_agent_ca       = data.local_file.consul_agent_ca.content
  consul_license        = var.consul_license
  consul_binary         = var.consul_binary 
  consul_encryption_key = var.consul_encryption_key  
}

module "aws-consul-gateway" {
  source  = "app.terraform.io/nickwales/aws-consul-gateway/module"
  version = "0.0.9"
  
  vpc_id = module.vpc.vpc_id
  region = var.region

  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets

  name  = var.name
  owner = var.owner

  consul_agent_ca       = data.local_file.consul_agent_ca.content
  consul_license        = var.consul_license
  consul_binary         = var.consul_binary 
  consul_encryption_key = var.consul_encryption_key

  target_groups = [aws_lb_target_group.gateway.arn]
}

module "aws-fake-service-connect" {
  source  = "app.terraform.io/nickwales/aws-fake-service-connect/module"
  version = "0.0.3"

  vpc_id = module.vpc.vpc_id
  region = var.region

  private_subnets = module.vpc.private_subnets

  name  = var.name
  owner = var.owner
  fake_service_name = "test-mesh"
  fake_service_message = "message"

  consul_agent_ca       = data.local_file.consul_agent_ca.content
  consul_license        = var.consul_license
  consul_binary         = var.consul_binary 
  consul_encryption_key = var.consul_encryption_key  
}
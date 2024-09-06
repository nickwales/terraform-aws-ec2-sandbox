module "aws-vault" {
  source  = "app.terraform.io/nickwales/aws-vault/module"
  version = "0.0.1"
  
  name  = var.name
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region

  private_subnets = module.vpc.private_subnets

  consul_agent_ca       = data.local_file.consul_agent_ca.content
  consul_license        = var.consul_license
  consul_binary         = var.consul_binary 
  consul_encryption_key = var.consul_encryption_key

  target_groups = [aws_lb_target_group.vault.arn]
}
module "consul_server_dc1" {
  source  = "github.com/nickwales/terraform-module-aws-consul-server?ref=0.0.9"  

  name  = var.name
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region

  private_subnets = module.vpc.private_subnets

  consul_server_key   = data.local_file.consul_server_key_dc1.content
  consul_server_cert  = data.local_file.consul_server_cert_dc1.content
  consul_agent_ca     = data.local_file.consul_agent_ca_dc1.content
  
  consul_encryption_key = var.consul_encryption_key
  
  consul_license = var.consul_license
  consul_binary  = var.consul_binary 

  target_groups = [aws_lb_target_group.consul_https_dc1.arn]
}

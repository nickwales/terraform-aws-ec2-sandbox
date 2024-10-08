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


module "nomad_server_dc1" {
  source  = "app.terraform.io/nickwales/aws-nomad-server/module"
  version = "0.0.5"

  name  = var.name
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region
  datacenter = "dc1"

  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets

  consul_ca_file = data.local_file.consul_agent_ca.content
  consul_binary  = var.consul_binary
  consul_encryption_key = var.consul_encryption_key

  nomad_bootstrap_token = data.local_file.nomad_bootstrap_token.content

  key_file  = data.local_file.consul_server_key.content
  cert_file = data.local_file.consul_server_cert.content
  ca_file   = data.local_file.consul_agent_ca.content

  target_groups = [aws_lb_target_group.nomad.arn]
}

module "nomad_client_dc1" {
  source  = "app.terraform.io/nickwales/aws-nomad-client/module"
  version = "0.0.5"

  name  = var.name
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region
  datacenter = "dc1"

  nomad_client_count = 2

  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets

  consul_ca_file = data.local_file.consul_agent_ca.content
  consul_encryption_key = var.consul_encryption_key

  ca_file   = data.local_file.consul_agent_ca.content
  key_file  = ""
  cert_file = ""

  target_groups = [aws_lb_target_group.gateway.arn]
}
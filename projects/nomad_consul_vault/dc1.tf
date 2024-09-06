module "consul_server_dc1" {
  source = "../../modules/consul_server"

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

  target_groups = [aws_lb_target_group.consul.arn]
}

module "nomad_server" {
  source = "../../modules/nomad_server"

  name  = var.name
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region
  datacenter = "dc1"

  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets

  consul_ca_file = data.local_file.consul_agent_ca_dc1.content
  consul_binary  = var.consul_binary

  consul_encryption_key = var.consul_encryption_key

  key_file  = data.local_file.consul_server_key_dc1.content
  cert_file = data.local_file.consul_server_cert_dc1.content
  ca_file   = data.local_file.consul_agent_ca_dc1.content

  nomad_bootstrap_token = var.nomad_bootstrap_token
  nomad_license         = var.nomad_license

  target_groups = [aws_lb_target_group.nomad.arn]
}

module "nomad_client" {
  source = "../../modules/nomad_client"

  name  = var.name
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region
  datacenter = "dc1"

  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets

  consul_ca_file = data.local_file.consul_agent_ca_dc1.content
  consul_binary  = var.consul_binary

  consul_encryption_key = var.consul_encryption_key

  key_file  = data.local_file.consul_server_key_dc1.content
  cert_file = data.local_file.consul_server_cert_dc1.content
  ca_file   = data.local_file.consul_agent_ca_dc1.content

  nomad_bootstrap_token = var.nomad_bootstrap_token
  nomad_client_count = 1
  target_groups = [aws_lb_target_group.mesh.arn]
}

module "vault" {
  source = "../../modules/vault"

  name  = var.name
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region
  consul_datacenter = "dc1"

  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets

  consul_agent_ca = data.local_file.consul_agent_ca_dc1.content
  consul_binary  = var.consul_binary

  consul_encryption_key = var.consul_encryption_key

  target_groups = [aws_lb_target_group.vault.arn]
}
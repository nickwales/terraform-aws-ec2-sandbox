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


module "nomad_server_dc1" {
  source  = "github.com/nickwales/terraform-module-aws-nomad-server?ref=0.0.7"

  name  = var.name
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region
  

  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets

  consul_ca_file = data.local_file.consul_agent_ca_dc1.content
  consul_binary  = var.consul_binary
  consul_encryption_key = var.consul_encryption_key

  nomad_region = "dc1"
  nomad_datacenter = "dc1"
  nomad_bootstrap_token = data.local_file.nomad_bootstrap_token_dc1.content

  key_file  = data.local_file.consul_server_key_dc1.content
  cert_file = data.local_file.consul_server_cert_dc1.content
  ca_file   = data.local_file.consul_agent_ca_dc1.content

  target_groups = [aws_lb_target_group.nomad_dc1.arn]
}

module "nomad_client_dc1" {
  source = "github.com/nickwales/terraform-module-aws-nomad-client?ref=0.0.12"  

  name  = var.name
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region
  datacenter = "dc1"

  nomad_region = "dc1"
  nomad_datacenter = "dc1"
  nomad_client_count = 3

  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets

  consul_ca_file = data.local_file.consul_agent_ca_dc1.content
  consul_encryption_key = var.consul_encryption_key
  consul_binary = var.consul_binary

  ca_file   = data.local_file.consul_agent_ca_dc1.content
  key_file  = ""
  cert_file = ""

  target_groups = [aws_lb_target_group.api_gateway_dc1.arn, aws_lb_target_group.mesh_gateway_dc1.arn]
}

module "nomad_client_partition_database_dc1" {
  source = "github.com/nickwales/terraform-module-aws-nomad-client?ref=0.0.12"  


  name  = var.name
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region
  datacenter = "dc1"

  nomad_region = "dc1"
  nomad_datacenter = "dc1"
  nomad_client_count = 1

  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets

  consul_ca_file = data.local_file.consul_agent_ca_dc1.content
  consul_encryption_key = var.consul_encryption_key
  consul_binary = var.consul_binary
  consul_partition = "database"

  ca_file   = data.local_file.consul_agent_ca_dc1.content
  key_file  = ""
  cert_file = ""
}

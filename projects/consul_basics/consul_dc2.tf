module "consul_server_dc2" {
  source = "../../modules/consul_server"

  name  = var.name
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region
  datacenter = "dc2"

  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets

  consul_server_key   = data.local_file.consul_server_key-dc2.content
  consul_server_cert  = data.local_file.consul_server_cert-dc2.content
  consul_agent_ca     = data.local_file.consul_agent_ca_dc2.content
  
  consul_license = var.consul_license
  consul_binary  = var.consul_binary   
}

module "consul_gateway_dc2" {
  source = "../../modules/consul_gateway"

  name  = var.name
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region
  datacenter = "dc2"

  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets

  consul_agent_ca = data.local_file.consul_agent_ca_dc2.content
  
  consul_license = var.consul_license
  consul_binary  = var.consul_binary 
}

module "consul_middleware_dc2" {
  source = "../../modules/middleware"

  name   = var.name
  owner  = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region
  
  datacenter = "dc2"
  partition  = var.dc2_middleware_partition
  
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets

  consul_agent_ca = data.local_file.consul_agent_ca_dc2.content
  
  consul_license = var.consul_license
  consul_binary  = var.consul_binary
  
}

module "consul_backend_dc2" {
  source = "../../modules/backend"

  name  = var.name
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region
  datacenter = "dc2"
  partition = var.dc2_backend_partition

  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets

  consul_agent_ca = data.local_file.consul_agent_ca_dc2.content
  
  consul_license = var.consul_license
  consul_binary  = var.consul_binary
}

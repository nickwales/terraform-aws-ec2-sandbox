module "nlb_dc2" {
  source = "../../modules/nlb"

  name    = "${var.name}-dc2"
  region  = var.region
  vpc_id  = module.vpc.vpc_id
  owner   = var.owner

  subnets = module.vpc.public_subnets
}

module "consul_server_dc2" {
  source = "../../modules/consul_server"

  name  = var.name
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region
  datacenter = "dc2"

  private_subnets = module.vpc.private_subnets

  consul_server_key   = data.local_file.consul_server_key-dc2.content
  consul_server_cert  = data.local_file.consul_server_cert-dc2.content
  consul_agent_ca     = data.local_file.consul_agent_ca_dc2.content
  
  consul_license = var.consul_license
  consul_binary  = var.consul_binary

  target_groups = [module.nlb_dc2.consul_target_group_arn]
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
  source = "../../modules/fake-service"

  name  = "middleware"
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region

  private_subnets = module.vpc.private_subnets
  
  consul_datacenter = "dc2"
  consul_partition  = var.middleware_partition
  consul_namespace  = "secure"  
  consul_agent_ca = data.local_file.consul_agent_ca_dc2.content
  consul_license = var.consul_license
  consul_binary  = var.consul_binary

  consul_agent_token = "30000000-0000-0000-0000-000000000001"

  upstream_uris = "http://backend.service.datastores.sg.postgres.ns.datastores.ap.consul:8080"
}



module "backend_dc2" {
  source = "../../modules/fake-service"

  name  = "backend"
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region
  consul_datacenter = "dc2"
  consul_partition = var.backend_partition
  consul_namespace = "postgres"

  private_subnets = module.vpc.private_subnets

  consul_agent_ca = data.local_file.consul_agent_ca_dc2.content
  
  consul_license = var.consul_license
  consul_binary  = var.consul_binary

  consul_agent_token = "30000000-0000-0000-0000-000000000002"
}

module "search_dc2" {
  source = "../../modules/fake-service"

  name  = "search"
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region

  private_subnets = module.vpc.private_subnets
  
  consul_datacenter = "dc2"
  consul_partition  = var.middleware_partition
  consul_namespace  = "insecure"
  consul_agent_ca = data.local_file.consul_agent_ca_dc2.content
  consul_license = var.consul_license
  consul_binary  = var.consul_binary
  consul_agent_token = "30000000-0000-0000-0000-000000000001"
}
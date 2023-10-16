module "nlb_dc1" {
  source = "../../modules/nlb"

  region  = var.region
  vpc_id  = module.vpc.vpc_id
  owner   = var.owner

  subnets = module.vpc.public_subnets
}

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
  
  consul_license = var.consul_license
  consul_binary  = var.consul_binary 

  target_groups = [module.nlb_dc1.consul_target_group_arn]
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


module "frontend_dc1" {
  source = "../../modules/fake-service"

  name  = "frontend"
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region
  consul_datacenter = "dc1"
  consul_partition = "ui"
  consul_namespace = "public"

  private_subnets = module.vpc.private_subnets

  consul_agent_ca = data.local_file.consul_agent_ca_dc1.content
  
  consul_license = var.consul_license
  consul_binary  = var.consul_binary  

 #upstream_uris = "http://middleware.service.secure.ns.global-api.ap.consul:8080,http://middleware.service.secure.ns.global-api.ap.dc2-global-api.peer.consul:8080,http://middleware.service.global-api.sg.secure.ns.global-api.ap.consul:8080"
  upstream_uris = "http://product-api.service.insecure.ns.global-api.ap.consul:8080,http://middleware.service.global-api.sg.secure.ns.global-api.ap.consul:8080"
  target_groups = [module.nlb_dc1.app_target_group_arn]

  consul_agent_token = "30000000-0000-0000-0000-000000000000"
}

module "consul_middleware_dc1" {
  source = "../../modules/fake-service"

  name  = "middleware"
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region

  private_subnets = module.vpc.private_subnets
  
  consul_datacenter = "dc1"
  consul_partition  = var.middleware_partition
  consul_namespace  = "secure"
  consul_agent_ca = data.local_file.consul_agent_ca_dc1.content
  consul_license = var.consul_license
  consul_binary  = var.consul_binary
  consul_agent_token = "30000000-0000-0000-0000-000000000001"

  upstream_uris = "http://backend.service.datastores.sg.postgres.ns.datastores.ap.consul:8080"
}

module "product_api_dc1" {
  source = "../../modules/fake-service"

  name  = "product-api"
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region

  private_subnets = module.vpc.private_subnets
  
  consul_datacenter = "dc1"
  consul_partition  = var.middleware_partition
  consul_namespace  = "insecure"
  consul_agent_ca = data.local_file.consul_agent_ca_dc1.content
  consul_license = var.consul_license
  consul_binary  = var.consul_binary
  consul_agent_token = "30000000-0000-0000-0000-000000000001"
}
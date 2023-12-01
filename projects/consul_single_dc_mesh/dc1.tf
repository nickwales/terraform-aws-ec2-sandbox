# module "nlb_dc1" {
#   source = "../../modules/nlb"

#   region  = var.region
#   vpc_id  = module.vpc.vpc_id
#   owner   = var.owner

#   subnets = module.vpc.public_subnets
# }

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

  target_groups = [aws_lb_target_group.consul.arn]
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

  target_groups = [aws_lb_target_group.frontend.arn]
}


module "frontend_dc1" {
  source = "../../modules/fake-service-connect"

  name  = "frontend"
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region
  consul_datacenter = "dc1"
  consul_partition = "default"
  consul_namespace = "default"

  private_subnets = module.vpc.private_subnets

  consul_agent_ca = data.local_file.consul_agent_ca_dc1.content
  
  consul_license = var.consul_license
  consul_binary  = var.consul_binary  

  upstream_uris = "http://middleware.virtual.default.ns.consul"

}

module "consul_middleware_dc1" {
  source = "../../modules/fake-service-connect"

  name  = "middleware"
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region

  private_subnets = module.vpc.private_subnets
  
  consul_datacenter = "dc1"
  consul_partition  = "default"
  consul_namespace  = "default"
  consul_agent_ca = data.local_file.consul_agent_ca_dc1.content
  consul_license = var.consul_license
  consul_binary  = var.consul_binary
  
  upstream_uris = "http://database.virtual.default.ns.consul"
}

module "consul_database_dc1" {
  source = "../../modules/fake-service-connect"

  name  = "database"
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region

  private_subnets = module.vpc.private_subnets
  
  consul_datacenter = "dc1"
  consul_partition  = "default"
  consul_namespace  = "default"
  consul_agent_ca = data.local_file.consul_agent_ca_dc1.content
  consul_license = var.consul_license
  consul_binary  = var.consul_binary
}

module "consul_telemetry_collector_dc1" {
  source = "../../modules/consul-telemetry-collector"

  name  = "consul-telemetry-collector"
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region

  private_subnets = module.vpc.private_subnets
  
  consul_datacenter = "dc1"
  consul_partition  = "default"
  consul_namespace  = "default"
  consul_agent_ca = data.local_file.consul_agent_ca_dc1.content
  consul_license = var.consul_license
  consul_binary  = var.consul_binary
  
  hcp_client_id = var.hcp_client_id
  hcp_client_secret = var.hcp_client_secret
  hcp_resource_id = var.hcp_resource_id
  
}


### Service discovery

module "service_a_dc1" {
  source = "../../modules/fake-service"

  name  = "service-a"
  service_tags = ["gary"]
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region

  private_subnets = module.vpc.private_subnets
  
  consul_datacenter = "dc1"
  consul_partition  = "default"
  consul_namespace  = "default"
  consul_agent_ca = data.local_file.consul_agent_ca_dc1.content
  consul_license = var.consul_license
  consul_binary  = var.consul_binary
  
  upstream_uris = "http://service-b.service.consul:8080,http://v1_0.service-b.service.consul:8080,http://v1_1.service-b.service.consul:8080"

  target_groups = [aws_lb_target_group.app.arn]
}

module "service_b_dc1" {
  source = "../../modules/fake-service"

  name         = "service-b"
  service_tags = ["v1_0"]

  owner  = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region

  private_subnets = module.vpc.private_subnets
  
  consul_datacenter = "dc1"
  consul_partition  = "default"
  consul_namespace  = "default"
  consul_agent_ca = data.local_file.consul_agent_ca_dc1.content
  consul_license = var.consul_license
  consul_binary  = var.consul_binary
}

module "service_b2_dc1" {
  source = "../../modules/fake-service"

  name           = "service-b"
  service_tags   = ["v1_1"]

  owner  = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region

  private_subnets = module.vpc.private_subnets
  
  consul_datacenter = "dc1"
  consul_partition  = "default"
  consul_namespace  = "default"
  consul_agent_ca = data.local_file.consul_agent_ca_dc1.content
  consul_license = var.consul_license
  consul_binary  = var.consul_binary
}
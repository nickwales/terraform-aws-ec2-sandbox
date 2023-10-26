module "nlb_dc1" {
  source = "../../modules/nlb"

  name    = "${var.name}-dc1"
  region  = var.region
  vpc_id  = module.vpc.vpc_id
  owner   = var.owner

  subnets = module.vpc.public_subnets
}

resource "aws_lb_listener" "consul_dc1" {
  load_balancer_arn = module.nlb_dc1.lb_arn
  port              = "8500"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consul_dc1.arn
  }
}

resource "aws_lb_target_group" "consul_dc1" {
  name        = "${var.name}-${var.datacenter}-consul"
  port        = 8500
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = module.nlb_dc1.lb_arn
  port              = "8080"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_lb_target_group" "app" {
  name        = "${var.name}-${var.datacenter}-app"
  port        = 8080
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
}

# Consul Server

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

  target_groups = [aws_lb_target_group.consul_dc1.arn]
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
  upstream_uris = "http://images.service.public.ns.dc2-ui.peer.consul:8080,http://search-api.service.external.ns.dc2-global-api.peer.consul:8080,http://products.query.consul:8080"
  target_groups = [aws_lb_target_group.app.arn]

  consul_agent_token = "30000000-0000-0000-0000-000000000000"
}

module "search_api_dc1" {
  source = "../../modules/fake-service"

  name  = "search-api"
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region

  private_subnets = module.vpc.private_subnets
  
  consul_datacenter = "dc1"
  consul_partition  = "global-api"
  consul_namespace  = "external"
  consul_agent_ca = data.local_file.consul_agent_ca_dc1.content
  consul_license = var.consul_license
  consul_binary  = var.consul_binary
  consul_agent_token = "30000000-0000-0000-0000-000000000001"

upstream_uris = "http://search-data.service.global-api.sg.internal.ns.global-api.ap.consul:8080"  
}

module "search_data_dc1" {
  source = "../../modules/fake-service"

  name  = "search-data"
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region

  private_subnets = module.vpc.private_subnets
  
  consul_datacenter = "dc1"
  consul_partition  = "global-api"
  consul_namespace  = "internal"
  consul_agent_ca = data.local_file.consul_agent_ca_dc1.content
  consul_license = var.consul_license
  consul_binary  = var.consul_binary
  consul_agent_token = "30000000-0000-0000-0000-000000000001"
}

module "products_dc1" {
  source = "../../modules/fake-service"

  name  = "products"
  message = "Elastic Search Product Dataset Sameness Group DC1"
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region
  consul_datacenter = "dc1"
  consul_partition = "datastores"
  consul_namespace = "elasticsearch"

  private_subnets = module.vpc.private_subnets

  consul_agent_ca = data.local_file.consul_agent_ca_dc1.content
  
  consul_license = var.consul_license
  consul_binary  = var.consul_binary  

  consul_agent_token = "30000000-0000-0000-0000-000000000002"
}
module "client_dc1" {
  source = "../../modules/fake-service"

  name  = "frontend"
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region

  private_subnets = module.vpc.private_subnets

  # Consul config
  consul_agent_ca   = data.local_file.consul_agent_ca.content
  consul_license    = var.consul_license
  consul_binary     = var.consul_binary  
  consul_retry_join = "a60f585d89f534f4f976addcc3008d0f-1444431896.us-east-1.elb.amazonaws.com"

  # Fake service Config 
  upstream_uris = "http://product-api.service.insecure.ns.global-api.ap.consul:8080,http://middleware.service.global-api.sg.secure.ns.global-api.ap.consul:8080"
}
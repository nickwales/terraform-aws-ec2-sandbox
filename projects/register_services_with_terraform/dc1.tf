module "nlb" {
  source = "../../modules/nlb"

  name    = "${var.name}"
  region  = var.region
  vpc_id  = module.vpc.vpc_id
  owner   = var.owner

  subnets = module.vpc.public_subnets
}

resource "aws_lb_listener" "consul" {
  load_balancer_arn = module.nlb.lb_arn
  port              = "8500"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consul.arn
  }
}

resource "aws_lb_target_group" "consul" {
  name        = "${var.name}-${var.datacenter}-consul"
  port        = 8500
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_listener" "nomad" {
  load_balancer_arn = module.nlb.lb_arn
  port              = "4646"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nomad.arn
  }
}

resource "aws_lb_target_group" "nomad" {
  name        = "${var.name}-${var.datacenter}-nomad"
  port        = 4646
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = module.nlb.lb_arn
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

resource "aws_lb_listener" "app_8081" {
  load_balancer_arn = module.nlb.lb_arn
  port              = "8081"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_8081.arn
  }
}

resource "aws_lb_target_group" "app_8081" {
  name        = "${var.name}-${var.datacenter}-app-8081"
  port        = 8081
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
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
  nomad_client_count = 2
  target_groups = [aws_lb_target_group.app.arn, aws_lb_target_group.app_8081.arn]
}
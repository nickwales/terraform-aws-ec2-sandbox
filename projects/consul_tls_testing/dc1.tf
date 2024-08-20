module "nlb" {
  source = "../../modules/nlb"

  name    = "${var.name}"
  region  = var.region
  vpc_id  = module.vpc.vpc_id
  owner   = var.owner

  subnets = module.vpc.public_subnets
}

# resource "aws_lb_listener" "consul" {
#   load_balancer_arn = module.nlb.lb_arn
#   port              = "8500"
#   protocol          = "TCP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.consul.arn
#   }
# }

# resource "aws_lb_target_group" "consul" {
#   name        = "${var.name}-${var.datacenter}-consul"
#   port        = 8500
#   protocol    = "TCP"
#   vpc_id      = module.vpc.vpc_id
# }

resource "aws_lb_listener" "consul_https" {
  load_balancer_arn = module.nlb.lb_arn
  port              = "8501"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consul_https.arn
  }
}

resource "aws_lb_target_group" "consul_https" {
  name        = "${var.name}-${var.datacenter}-consul-https"
  port        = 8501
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
}

module "consul_server_dc1" {

  source  = "app.terraform.io/nickwales/aws-consul-server/module"
  version = "0.0.5"

  name  = var.name
  owner = var.owner
  vpc_id = module.vpc.vpc_id
  region = var.region

  private_subnets = module.vpc.private_subnets

  consul_server_key   = data.local_file.consul_server_key_dc1.content
  consul_server_cert  = data.local_file.consul_server_cert_dc1.content
  consul_agent_ca     = data.local_file.consul_agent_ca_dc1.content
  
  consul_server_count   = 3
  consul_encryption_key = var.consul_encryption_key
  
  consul_license = var.consul_license
  consul_binary  = var.consul_binary 

  target_groups = [aws_lb_target_group.consul_https.arn]
}

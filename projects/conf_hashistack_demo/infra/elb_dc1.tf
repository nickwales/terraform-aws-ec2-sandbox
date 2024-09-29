resource "aws_lb" "lb_dc1" {
  name               = "${var.name}-${var.datacenter}"
  internal           = false
  load_balancer_type = "network"
  enable_cross_zone_load_balancing = true
  #security_groups    = [aws_security_group.lb.id]
  subnets            = module.vpc.public_subnets

  tags = {
    Owner = var.owner
  }     
}


## Consul HTTPS UI
resource "aws_lb_target_group" "consul_https_dc1" {
  name        = "${var.name}-${var.datacenter}-consul-https"
  port        = 8501
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_listener" "consul_https_dc1" {
  load_balancer_arn = aws_lb.lb_dc1.arn
  port              = 8501
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consul_https_dc1.arn
  }
}

## Nomad UI 
resource "aws_lb_target_group" "nomad_dc1" {
  name        = "${var.name}-${var.datacenter}-nomad"
  port        = 4646
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_listener" "nomad_dc1" {
  load_balancer_arn = aws_lb.lb_dc1.arn
  port              = 4646
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nomad_dc1.arn
  }
}

## API Gateway
resource "aws_lb_target_group" "api_gateway_dc1" {
  name        = "${var.name}-${var.datacenter}-api-gateway"
  port        = 8088
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_listener" "api_gateway_dc1" {
  load_balancer_arn = aws_lb.lb_dc1.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_gateway_dc1.arn
  }
}

## Mesh Gateway
resource "aws_lb_target_group" "mesh_gateway_dc1" {
  name        = "${var.name}-${var.datacenter}-mesh-gateway"
  port        = 8443
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_listener" "mesh_gateway_dc1" {
  load_balancer_arn = aws_lb.lb_dc1.arn
  port              = 8443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mesh_gateway_dc1.arn
  }
}

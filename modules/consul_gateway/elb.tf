resource "aws_lb" "consul_gateway" {
  name               = "${var.name}-${var.datacenter}-consul-gateway"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.consul_gateway_sg.id]
  subnets            = var.private_subnets

  tags = {
    Owner = var.owner
  }     
}

resource "aws_lb_listener" "consul_gateway" {
  load_balancer_arn = aws_lb.consul_gateway.arn
  port              = "8443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consul_gateway.arn
  }
}

resource "aws_lb_target_group" "consul_gateway" {
  name        = "${var.name}-${var.datacenter}-consul-gateway"
  port        = 8500
  protocol    = "TCP"
  vpc_id      = var.vpc_id
}


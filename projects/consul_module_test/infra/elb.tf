resource "aws_lb" "lb" {
  name               = "${var.name}-${var.datacenter}"
  internal           = false
  load_balancer_type = "network"
  #security_groups    = [aws_security_group.lb.id]
  subnets            = module.vpc.public_subnets

  tags = {
    Owner = var.owner
  }     
}

resource "aws_lb_listener" "consul" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 8500
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

resource "aws_lb_listener" "consul_https" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 8501
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


resource "aws_lb_listener" "gateway" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gateway.arn
  }
}

resource "aws_lb_target_group" "gateway" {
  name        = "${var.name}-${var.datacenter}-gateway"
  port        = 8081
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
}


resource "aws_lb_listener" "nomad" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 4646
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
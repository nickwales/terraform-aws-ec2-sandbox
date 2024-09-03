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

resource "aws_lb_listener" "application" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application.arn
  }
}

resource "aws_lb_target_group" "application" {
  name        = "${var.name}-${var.datacenter}-application"
  port        = 80
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_listener" "asp" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 81
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asp.arn
  }
}

resource "aws_lb_target_group" "asp" {
  name        = "${var.name}-${var.datacenter}-asp"
  port        = 81
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_listener" "static" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 82
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.static.arn
  }
}

resource "aws_lb_target_group" "static" {
  name        = "${var.name}-${var.datacenter}-static"
  port        = 82
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_listener" "framework" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 83
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.framework.arn
  }
}

resource "aws_lb_target_group" "framework" {
  name        = "${var.name}-${var.datacenter}-framework"
  port        = 83
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_listener" "traefik" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 8080
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.traefik.arn
  }
}

resource "aws_lb_target_group" "traefik" {
  name        = "${var.name}-${var.datacenter}-traefik"
  port        = 8080
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_listener" "rdp" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 3389
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rdp.arn
  }
}

resource "aws_lb_target_group" "rdp" {
  name        = "${var.name}-${var.datacenter}-rdp"
  port        = 3389
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_listener" "vault" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 8200
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault.arn
  }
}

resource "aws_lb_target_group" "vault" {
  name        = "${var.name}-${var.datacenter}-vault"
  port        = 8200
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
}
resource "aws_lb" "lb" {
  name               = "${var.name}-${var.datacenter}"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.lb.id]
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



resource "aws_lb_listener" "mesh" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mesh.arn
  }
}

resource "aws_lb_target_group" "mesh" {
  name        = "${var.name}-${var.datacenter}-mesh"
  port        = 8080
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_listener" "discovery" {
  load_balancer_arn = aws_lb.lb.arn
  port              = 8080
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.discovery.arn
  }
}

resource "aws_lb_target_group" "discovery" {
  name        = "${var.name}-${var.datacenter}-discovery"
  port        = 8080
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
}
resource "aws_lb" "lb" {
  name               = "${var.name}-${var.consul_datacenter}"
  internal           = var.internal
  load_balancer_type = "network"
  security_groups    = [aws_security_group.lb_security_group.id]
  subnets            = var.subnets

  tags = {
    Owner = var.owner
  }     
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_lb_target_group" "app" {
  name        = "${var.name}-${var.consul_datacenter}-app"
  port        = 8080
  protocol    = "TCP"
  vpc_id      = var.vpc_id
}


resource "aws_lb_listener" "consul" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "8500"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consul.arn
  }
}

resource "aws_lb_target_group" "consul" {
  name        = "${var.name}-${var.consul_datacenter}-consul"
  port        = 8500
  protocol    = "TCP"
  vpc_id      = var.vpc_id
}

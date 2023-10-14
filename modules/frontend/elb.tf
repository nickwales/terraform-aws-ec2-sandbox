resource "aws_lb" "frontend" {
  name               = "${var.name}-${var.datacenter}-frontend"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.lb.id]
  subnets            = var.public_subnets

  tags = {
    Owner = var.owner
  }     
}

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_lb_target_group" "frontend" {
  name        = "${var.name}-${var.datacenter}-frontend"
  port        = 8080
  protocol    = "TCP"
  vpc_id      = var.vpc_id
}


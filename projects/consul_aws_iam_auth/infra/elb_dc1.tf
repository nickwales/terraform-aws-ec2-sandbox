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

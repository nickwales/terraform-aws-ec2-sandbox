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

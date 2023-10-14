# resource "aws_lb" "consul_server_lb" {
#   name               = "${var.name}-${var.datacenter}"
#   internal           = false
#   load_balancer_type = "network"
#   security_groups    = [aws_security_group.consul_server_sg.id]
#   subnets            = var.public_subnets

#   tags = {
#     Owner = var.owner
#   }     
# }

# resource "aws_lb_listener" "consul" {
#   load_balancer_arn = aws_lb.consul_server_lb.arn
#   port              = 8500
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
#   vpc_id      = var.vpc_id
# }


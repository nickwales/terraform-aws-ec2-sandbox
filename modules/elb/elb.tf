resource "aws_lb" "lb" {
  name               = var.name
  internal           = false
  load_balancer_type = "network"
  security_groups    = var.security_groups
  subnets            = module.vpc.public_subnet

  tags = {
    Owner = var.owner
    se_region = var.region
  }     
}

# resource "aws_lb_listener" "frontend" {
#   load_balancer_arn = aws_lb.lb.arn
#   port              = "80"
#   protocol          = "TCP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.frontend.arn
#   }
# }

# resource "aws_lb_target_group" "frontend" {
#   name        = "${var.name}-frontend"
#   port        = 80
#   protocol    = "TCP"
#   vpc_id      = module.vpc.vpc_id
# }


# resource "aws_lb_listener" "consul" {
#   load_balancer_arn = aws_lb.lb.arn
#   port              = "8500"
#   protocol          = "TCP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.consul.arn
#   }
# }

# resource "aws_lb_target_group" "consul" {
#   name        = "${var.name}-consul"
#   port        = 8500
#   protocol    = "TCP"
#   vpc_id      = module.vpc.vpc_id
# }

# resource "aws_lb_listener" "stats" {
#   load_balancer_arn = aws_lb.lb.arn
#   port              = "9000"
#   protocol          = "TCP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.stats.arn
#   }
# }

# resource "aws_lb_target_group" "stats" {
#   name        = "${var.name}-stats"
#   port        = 9000
#   protocol    = "TCP"
#   vpc_id      = module.vpc.vpc_id
# }
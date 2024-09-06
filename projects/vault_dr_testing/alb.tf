resource "aws_alb" "hashistack" {
  name               = var.name
  internal           = false
  load_balancer_type = "network"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.load_balancer_security_group.id]

  tags = {
    Name        = var.name

  }
}

resource "aws_lb_listener" "consul" {
  load_balancer_arn = aws_alb.hashistack.arn
  port              = "8500"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.consul.arn
  }
}

resource "aws_lb_target_group" "consul" {
  name        = "consul"
  port        = 8500
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id

  health_check {
    healthy_threshold   = "2"
    interval            = "10"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/v1/status/leader"
    unhealthy_threshold = "2"
  }

  tags = {
    Name        = "consul"
  }
}

resource "aws_lb_listener" "vault" {
  load_balancer_arn = aws_alb.hashistack.arn
  port              = "8200"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault.arn
  }
}

resource "aws_lb_target_group" "vault" {
  name        = "vault"
  port        = 8200
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id

  health_check {
    healthy_threshold   = "2"
    interval            = "10"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/v1/sys/health"
    unhealthy_threshold = "2"
  }

  tags = {
    Name        = "vault_primary"
  }
}

resource "aws_lb_listener" "vault_secondary" {
  load_balancer_arn = aws_alb.hashistack.arn
  port              = "8201"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault_secondary.arn
  }
}

resource "aws_lb_target_group" "vault_secondary" {
  name        = "vault-secondary"
  port        = 8200
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id

  health_check {
    healthy_threshold   = "2"
    interval            = "10"
    protocol            = "HTTP"
    matcher             = "200,400-472"
    timeout             = "3"
    path                = "/v1/sys/health"
    unhealthy_threshold = "2"
  }

  tags = {
    Name        = "vault_secondary"
  }
}

resource "aws_security_group" "load_balancer_security_group" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port        = 8200
    to_port          = 8500
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name        = "sg"
  }
}
resource "aws_security_group" "consul_server" {
  name_prefix = var.name
  description = "Traffic For Consul Servers"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
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
}

# resource "aws_security_group_rule" "ssh" {
#   type             = "ingress"
#   from_port        = 22
#   to_port          = 22
#   protocol         = "tcp"
#   cidr_blocks      = module.vpc.private_subnets_cidr_blocks
#   security_group_id = aws_security_group.consul_server.id
# }

# resource "aws_security_group_rule" "consul_ui" {
#   type              = "ingress"
#   from_port         = 8500
#   to_port           = 8500
#   protocol          = -1
#   cidr_blocks       = module.vpc.private_subnets_cidr_blocks
#   security_group_id = aws_security_group.consul_server.id
# }

# resource "aws_security_group_rule" "consul_dns" {
#   type              = "ingress"
#   from_port         = 8600
#   to_port           = 8600
#   protocol          = "udp"
#   cidr_blocks       = module.vpc.private_subnets_cidr_blocks
#   security_group_id = aws_security_group.consul_server.id
# }


resource "aws_security_group" "route53_endpoints" {
  name_prefix = var.name
  description = "Route53 Endpoint"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "All access" # needs tightening but idk what traffic is coming in yet
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]    
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = module.vpc.private_subnets_cidr_blocks
    ipv6_cidr_blocks = ["::/0"]
  }
}



### ECS

resource "aws_security_group" "example_client_app" {
  name   = "${var.name}-example-client-app-alb"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Access to example client application."
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ingress_from_client_alb_to_ecs" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "all"
  source_security_group_id = aws_security_group.example_client_app.id
  security_group_id        = module.vpc.default_security_group_id
  #security_group_id        = data.aws_security_group.vpc_default.id
}


resource "aws_security_group" "apps" {
  name_prefix = "apps"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }

  tags = {
    Name = "nwales"
  }  
}
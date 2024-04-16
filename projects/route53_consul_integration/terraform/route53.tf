resource "aws_route53_resolver_endpoint" "consul" {
  name      = "consul"
  direction = "OUTBOUND"

  security_group_ids = [
    aws_security_group.route53_endpoints.id
  ]

  ip_address {
    subnet_id = module.vpc.private_subnets[0]
  }

  ip_address {
    subnet_id = module.vpc.private_subnets[1]
  }

  tags = {
    Environment = "Prod"
  }
}


resource "aws_route53_resolver_rule" "consul_forward" {
  domain_name          = "consul"
  name                 = "Consul"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.consul.id

  target_ip {
    ip   = aws_instance.consul_server.private_ip
    port = 8600
  }

  tags = {
    Environment = "Prod"
  }
}

resource "aws_route53_resolver_rule_association" "consul" {
  resolver_rule_id = aws_route53_resolver_rule.consul_forward.id
  vpc_id           = module.vpc.vpc_id
}
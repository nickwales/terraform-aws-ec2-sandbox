module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.name
  cidr = var.cidr

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.name
    Owner = var.owner
    Purpose = var.purpose
  }
}

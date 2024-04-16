module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.name
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_ipv6                                    = true
  private_subnet_assign_ipv6_address_on_creation = true
  private_subnet_ipv6_prefixes                   = [0, 1]  

  tags = {
    Terraform = "true"
    Environment = "dev"
    ttl = 72
    hc-internet-facing = "true"
    Name = var.name
    Owner = "nwales"
    Purpose = "Sandbox Testing"
    se_region = "AMER"
  }
}

# module "vpc2" {
#   source = "terraform-aws-modules/vpc/aws"

#   name = var.name
#   cidr = "10.1.0.0/16"

#   azs             = ["us-east-1a", "us-east-1b"]
#   private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
#   public_subnets  = ["10.1.101.0/24", "10.1.102.0/24"]

#   enable_nat_gateway = true
#   enable_vpn_gateway = true

#   enable_dns_hostnames = true
#   enable_dns_support   = true

#   tags = {
#     Terraform = "true"
#     Environment = "dev"
#     ttl = 72
#     hc-internet-facing = "true"
#     Name = var.name
#     Owner = "nwales"
#     Purpose = "Sandbox Testing"
#     se_region = "AMER"
#   }
# }
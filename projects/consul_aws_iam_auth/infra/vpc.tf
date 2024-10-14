module "vpc" {
  source = "github.com/nickwales/terraform-module-aws-vpc?ref=0.0.0"
  region = var.region
  name   = var.name
  
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

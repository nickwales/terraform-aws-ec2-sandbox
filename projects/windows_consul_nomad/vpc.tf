module "vpc" {
  source = "../../modules/vpc"
  region = var.region
  name   = var.name
  
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

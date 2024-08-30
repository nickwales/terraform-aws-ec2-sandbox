module "eks_cluster" {
  source  = "app.terraform.io/nickwales/aws-eks/module"
  version = "0.0.2"
  
  name   = var.name
  region = var.region
    
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets

  instance_type = "t3.medium"
}

resource "kubernetes_namespace" "consul" {
  metadata {
    name = "consul"
  }
}
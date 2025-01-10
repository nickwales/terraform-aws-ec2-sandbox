module "eks_cluster_primary" {
    source = "../../modules/eks"
    name   = var.name
    region = var.region
    
    vpc_id          = module.vpc.vpc_id
    public_subnets  = module.vpc.public_subnets
    private_subnets = module.vpc.private_subnets
}

# resource "kubernetes_namespace" "consul" {
#   metadata {
#     name = "consul"
#   }
# }
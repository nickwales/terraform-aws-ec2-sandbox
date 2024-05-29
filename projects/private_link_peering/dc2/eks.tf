module "eks" {
  source = "../../../modules/eks"
  name   = var.name
  vpc_id = module.vpc.vpc_id
  
  public_subnets = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
}


# resource "helm_release" "consul" {
#   name             = "consul"
#   namespace        = "consul"
#   create_namespace = true
#   repository       = "https://helm.releases.hashicorp.com"
#   chart            = "consul"

#   depends_on = [module.eks]

#   set {
#     name  = "global.name"
#     value = "consul"
#   }

#   values = [
#     file("${path.module}/../helm/dc2.yaml")
#   ]
# }

# resource "kubernetes_manifest" "mesh" {
#   depends_on = [module.eks, helm_release.consul]
#   manifest = {
#     apiVersion = "consul.hashicorp.com/v1alpha1"
#     kind       = "Mesh"

#     metadata = {
#       name      = "mesh"
#       namespace = "consul"
#     }

#     spec = {
#       peering = {
#         peerThroughMeshGateways = true
#       }
#     }
#   }
# }

# resource "kubernetes_manifest" "exports" {
#   manifest = {
#     apiVersion = "consul.hashicorp.com/v1alpha1"
#     kind       = "ExportedServices"

#     metadata = {
#       name      = "mesh"
#       namespace = "consul"
#     }

#     spec = {
#       peering = {
#         peerThroughMeshGateways = true
#       }
#     }
#   }
# }
module "eks" {
  source = "../../../modules/eks"
  name   = var.name
  vpc_id = module.vpc.vpc_id
  
  public_subnets = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets

  desired_size = 3
}

# resource "kubernetes_manifest" "mesh" {
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

# resource "helm_release" "consul" {
#   name       = "consul"
#   namespace  = "consul"
#   repository = "https://helm.releases.hashicorp.com"
#   chart      = "consul"

#   depends_on = [module.eks.helm_release.aws_lb_controller]

#   set {
#     name  = "global.name"
#     value = "consul"
#   }

#   values = [
#     file("${path.module}/../helm/dc1.yaml")
#   ]
# }

# resource "kubernetes_service_account" "frontend" {
#   metadata {
#     name = "frontend"
#   }
# }

# resource "kubernetes_deployment" "frontend" {
#   metadata {
#     name = "frontend"
#     labels = {
#       test = "frontend"
#     }
#   }

#   spec {
#     replicas = 3

#     selector {
#       match_labels = {
#         test = "frontend"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           test = "frontend"
#         }
#       }

#       spec {
#         container {
#           image = "nicholasjackson/fake-service:v0.26.2"
#           name  = "frontend"

#           resources {
#             limits = {
#               cpu    = "0.5"
#               memory = "512Mi"
#             }
#             requests = {
#               cpu    = "250m"
#               memory = "50Mi"
#             }
#           }

#           liveness_probe {
#             http_get {
#               path = "/health"
#               port = 9090
#             }

#             initial_delay_seconds = 3
#             period_seconds        = 3
#           }
#         }
#       }
#     }
#   }
# }
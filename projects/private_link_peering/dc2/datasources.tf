# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#   #token                  = data.aws_eks_cluster_auth.cluster.token
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#   }  
# }

provider "aws" {
  region = var.region
}

# provider "helm" {
#   kubernetes {
#     host                   = module.eks.cluster_endpoint
#     cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#       command     = "aws"
#     }
#   }
# }

# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_id
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_id
# }

# provider "kubernetes" {
#   config_path    = "${path.module}/.kubeconfig"
#   config_context =  element(concat(data.aws_eks_cluster.cluster[*].arn, list("")), 0)
#   host                   = data.aws_eks_cluster.cluster.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#   token                  = data.aws_eks_cluster_auth.cluster.token
#   //load_config_file       = false
# }




# data "aws_eks_cluster" "cluster" {
#   name = module.eks_dc2.cluster_id
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks_dc2.cluster_id
# }

# provider "kubernetes_dc2" {
#   host                   = data.aws_eks_cluster.cluster_dc2.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster_dc2.certificate_authority.0.data)
#   token                  = data.aws_eks_cluster_auth.cluster_dc2.token
#   load_config_file       = false
# }
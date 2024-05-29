output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "name" {
  description = "Kubernetes Cluster Name"
  value       = var.name
}

output "cluster_certificate_authority_data" {
  description = "EKS Cert Authority data"
  value       = module.eks.cluster_certificate_authority_data
}

output "kubernetes_service_account" {
  value = kubernetes_service_account.service-account.id
}

output "cluster_name" {
  value = module.eks.cluster_name
}
output "lb_role" {
  value = module.lb_role.iam_role_arn
}
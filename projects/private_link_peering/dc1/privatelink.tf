# module "privatelink" {
#   source  = "BorisLabs/privatelink/aws"
#   version = "1.1.2"

#   allowed_principals = [ { "principal": var.allowed_principals, "tags": [ { "key": "Customer", "value": "vpc2" } ] } ]

#   network_load_balancer_arns = ["arn:aws:elasticloadbalancing:us-east-1:068591307351:loadbalancer/net/k8s-consul-consulme-ac28555908/5dceaa8a68993833"]
#   private_dns_name = var.private_dns_name
#   service_name     = var.service_name
# }
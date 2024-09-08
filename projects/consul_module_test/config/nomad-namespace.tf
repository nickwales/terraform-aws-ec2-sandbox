resource "nomad_namespace" "ingress" {
  name        = "ingress"
  description = "For ingress"
  meta        = {
    owner = "Consul API Gateway"
  }
}
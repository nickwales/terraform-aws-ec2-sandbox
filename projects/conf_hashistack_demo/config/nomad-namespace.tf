resource "nomad_namespace" "ingress" {
  name        = "ingress"
  description = "For ingress Services"
  meta        = {
    owner = "Consul API Gateway"
  }
}
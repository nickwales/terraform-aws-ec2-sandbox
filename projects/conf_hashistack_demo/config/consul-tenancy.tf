## Default Partition

resource "consul_namespace" "ingress" {
  name        = "ingress"
  description = "Namespace for Ingress Services"
}

resource "consul_admin_partition" "database" {
  name        = "database"
  description = "Database Partition"
}
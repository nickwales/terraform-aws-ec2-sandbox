resource "consul_intention" "test-mesh" {
  source_name      = "api-gateway"
  destination_name = "test-mesh"
  action           = "allow"
}
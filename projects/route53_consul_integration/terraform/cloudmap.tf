resource "aws_service_discovery_http_namespace" "dev" {
  name        = "development"
  description = "example"
}

resource "aws_service_discovery_service" "client" {
  name         = "client"
  namespace_id = aws_service_discovery_http_namespace.dev.id
}

resource "aws_service_discovery_service" "server" {
  name         = "server"
  namespace_id = aws_service_discovery_http_namespace.dev.id
}
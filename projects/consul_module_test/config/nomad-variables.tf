resource "nomad_variable" "name" {
  path = "nomad/jobs/api-gateway/gateway/setup" 
  namespace = nomad_namespace.ingress.name
  items = {
    consul_cacert = data.local_file.consul_agent_ca.content
    consul_client_cert = data.local_file.consul_server_cert.content
    consul_client_key = data.local_file.consul_server_key.content
  }
}
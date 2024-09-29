resource "consul_acl_policy" "anonymous" {
  name        = "anonymous"
  datacenters = [var.datacenter]
  rules       = <<-RULE
    node_prefix "" {
      policy = "read"
    }
    service_prefix "" {
      policy = "read"
    }
    mesh = "read"
    RULE
}

resource "consul_acl_token_policy_attachment" "anonymous" {
  token_id = "00000000-0000-0000-0000-000000000002"
  policy   = consul_acl_policy.anonymous.name
}

# resource "consul_acl_binding_rule" "api-gateway" {
#   auth_method = "nomad-workloads"
#   description = "Nomad API gateway"
#   selector    = "\"nomad_service\" not in value and value.nomad_namespace==ingress"

#   # bind_type   = "templated-policy"
#   # bind_name   = "builtin/api-gateway"

#   bind_type = "policy"
#   bind_name = "api-gateway"
#   # bind_vars {
#   #   name = "value.nomad_job_id"
#   # } 
# }

resource "consul_acl_policy" "api-gateway" {
  name        = "api-gateway"
  datacenters = ["dc1"]
  rules       = <<-RULE
    service "gateway" {
      policy = "write"
    }

    mesh = "read"  
    node_prefix "" {
      policy = "read"
    }
    service_prefix "" {
      policy = "read"
    }
    RULE
}


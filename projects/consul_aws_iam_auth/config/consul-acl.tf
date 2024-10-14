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



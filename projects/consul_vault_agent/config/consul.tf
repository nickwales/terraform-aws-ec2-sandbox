#Anonymous policy

resource "consul_acl_policy" "anonymous" {
  name        = "anonymous-policy"
  datacenters = ["dc1"]
  rules       = <<-RULE
agent_prefix "" {
  policy = "read"
}
node_prefix "" {
  policy = "write"
}

service_prefix "" {
  policy = "read"
}
    RULE
}

resource "consul_acl_token_policy_attachment" "anonymous" {
    token_id = "00000000-0000-0000-0000-000000000002"
    policy   = "${consul_acl_policy.anonymous.name}"
}

resource "consul_acl_policy" "esm_policy" {
  name        = "esm-policy"
  datacenters = ["dc1"]
  rules       = <<-RULE
agent_prefix "" {
  policy = "read"
}

key_prefix "consul-esm/" {
  policy = "write"
}

node_prefix "" {
  policy = "write"
}

service_prefix "" {
  policy = "write"
}

session_prefix "" {
   policy = "write"
}
RULE
}


resource "consul_acl_role" "esm_role" {
  name        = "esm-role"
  description = "Consul ESM Role"

  policies = [
    consul_acl_policy.esm_policy.id
  ]
}



resource "consul_acl_auth_method" "iam_auth" {
  name          = "iam_auth"
  type          = "aws-iam"
  description   = "IAM Auth Method"
  max_token_ttl = "3m"

  config_json = jsonencode({
    BoundIAMPrincipalARNs  = var.iam_entities
    EnableIAMEntityDetails = false
    #IAMEntityTags          = ["consul-namespace"]
    MaxRetries             = 3
    #ServerIDHeaderValue    = "my.consul.server.example.com"
    IAMEndpoint            = "https://iam.amazonaws.com/"
    STSEndpoint            = "https://sts.us-east-1.amazonaws.com/"
    AllowedSTSHeaderValues = ["X-Extra-Header"]
  })
}


resource "consul_acl_binding_rule" "admin" {
  auth_method = consul_acl_auth_method.iam_auth.name
  description = "Admin Login"
  selector    = "entity_name matches \"admin\"" # Matches a substring
  #selector    = "account_id==\"<account_id>\""
  #selector    = "entity_name==\"<full_role_name>\""
  bind_type   = "role"
  bind_name   = "admin"
}


resource "consul_acl_policy" "admin" {
  name        = "admin"
  datacenters = ["dc1"]
  rules       = <<-RULE
    node_prefix "" {
      policy = "write"
    }
    service_prefix "" {
      policy = "write"
    }
    RULE
}

resource "consul_acl_role" "admin" {
  name        = "admin"
  description = "Role with administrative privileges."

  policies = [
    consul_acl_policy.admin.id
  ]
}



resource "consul_acl_binding_rule" "developer" {
  auth_method = consul_acl_auth_method.iam_auth.name
  description = "Bind test"
  #selector    = "entity_name==\"<role>\""
  selector    = "entity_name matches \"developer\""
  #selector    = "account_id==\"<account_id>\""
  bind_type   = "role"
  bind_name   = "developer"
}


resource "consul_acl_policy" "developer" {
  name        = "developer"
  datacenters = ["dc1"]
  rules       = <<-RULE
    node_prefix "" {
      policy = "read"
    }
    service_prefix "" {
      policy = "read"
    }
    RULE
}

resource "consul_acl_role" "developer" {
  name        = "developer"
  description = "Role with developer privileges."

  policies = [
    consul_acl_policy.developer.id
  ]
}
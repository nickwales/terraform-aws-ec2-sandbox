path "secret/data/{{identity.entity.aliases.auth_jwt_3a9350fe.metadata.nomad_namespace}}/{{identity.entity.aliases.auth_jwt_3a9350fe.metadata.nomad_job_id}}/*" {
  capabilities = ["read"]
}

path "secret/data/{{identity.entity.aliases.auth_jwt_3a9350fe.metadata.nomad_namespace}}/{{identity.entity.aliases.auth_jwt_3a9350fe.metadata.nomad_job_id}}" {
  capabilities = ["read"]
}

path "secret/metadata/{{identity.entity.aliases.auth_jwt_3a9350fe.metadata.nomad_namespace}}/*" {
  capabilities = ["list"]
}

path "secret/metadata/*" {
  capabilities = ["list"]
}


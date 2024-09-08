resource "nomad_job" "frontend" {
  jobspec = file("${path.module}/jobs/frontend.nomad.hcl")
}

resource "nomad_job" "backend" {
  jobspec = file("${path.module}/jobs/backend.nomad.hcl")
}

resource "nomad_job" "api-gateway" {
  jobspec = file("${path.module}/jobs/gateway.nomad.hcl")
}

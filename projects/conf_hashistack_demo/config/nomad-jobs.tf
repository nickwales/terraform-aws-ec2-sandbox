resource "nomad_job" "api-gateway" {
  jobspec = file("${path.module}/jobs/api-gateway.nomad.hcl")

  hcl2 {
    vars = {
      "partition"  = "default"
    }
  }
}

resource "nomad_job" "frontend" {
  jobspec = file("${path.module}/jobs/frontend.nomad.hcl")

  hcl2 {
    vars = {
      "job_region" = var.job_region
      "partition"  = "default"
    }
  }
}

resource "nomad_job" "backend" {
  jobspec = file("${path.module}/jobs/backend.nomad.hcl")

  hcl2 {
    vars = {
      "job_region" = var.job_region
      "partition"  = "default"
    }
  }
}

resource "nomad_job" "redis" {
  jobspec = file("${path.module}/jobs/redis.nomad.hcl")

  hcl2 {
    vars = {
      "job_region" = var.job_region
      "partition"  = "default"
    }
  }
}


# resource "nomad_job" "backend_database" {
#   jobspec = file("${path.module}/jobs/backend_database.nomad.hcl")

#   hcl2 {
#     vars = {
#       "job_region" = var.job_region
#       "partition"  = "database"
#     }
#   }
# }

resource "nomad_job" "database" {
  jobspec = file("${path.module}/jobs/database.nomad.hcl")

  hcl2 {
    vars = {
      "job_region" = var.job_region,
      "partition"  = "database"
    }
  }
}

# resource "nomad_job" "api-gateway" {
#   jobspec = file("${path.module}/jobs/gateway.nomad.hcl")
# }

# Namespaces

resource "nomad_namespace" "operations" {
  name        = "operations"
  description = "Operations"

  meta        = {
    owner = "Dr Operation"
  }
}

resource "nomad_namespace" "database" {
  name        = "database"
  description = "Where databases live"

  meta        = {
    owner = "Jonny Drop-Tables"
  }
}

resource "nomad_namespace" "applications" {
  name        = "applications"
  description = "Application Deployments"

  meta        = {
    owner = "Mr Applicable"
  }
}
variable "version" {
  type = string
}

job "middleware" {

  datacenters = ["dc1"]
  type = "service"
  namespace = "applications"

  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  group "middleware" {
    count = 2

    scaling {
      enabled = true
      min     = 1
      max     = 3
    }

    network {
      port "http" {}
    }        

    update {
      health_check  = "checks"
      auto_revert   = true
      auto_promote  = false
      canary        = 1
      max_parallel  = 1
      stagger       = "10s"
    }

    service {
      name = "middleware"
      port = "http"

      check {
        type     = "tcp"
        interval = "30s"
        timeout  = "5s" 
      }

      tags = [
          "version=${var.version}",
          "traefik.enable=true",
          "traefik.http.routers.middleware.rule=Host(`middleware.service.consul`)",
          "traefik.http.routers.middleware.entrypoints=http",          
      ]
    }          

    task "middleware" {
      driver = "docker"

      config {
        image = "nicholasjackson/fake-service:v0.26.2"
        ports = ["http"]
      }

      env {
        NAME = "middleware - version ${var.version}"
        UPSTREAM_URIS = "http://mssql.service.consul:18900"
      }

      template {
        data        = <<EOF
{{with secret "secret/data/applications/middleware/config"}}
MESSAGE="Instance #{{ env "NOMAD_ALLOC_INDEX"}} - {{.Data.data.message}}"
LISTEN_ADDR="0.0.0.0:{{ env "NOMAD_PORT_http" }}"
{{end}}
EOF
        change_mode = "restart"
        destination = "${NOMAD_SECRETS_DIR}/config.env"
        env         = true
        splay       = "10s"
      }

      vault {}      
    }
  }
}

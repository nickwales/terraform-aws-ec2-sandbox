job "frontend" {

  datacenters = ["dc1"]
  type = "service"
  namespace = "applications"

  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  group "frontend" {
    count = 2

    network {
      port "http" {
        to     = 9090
      }
    }        

    update {
      health_check  = "checks"
      max_parallel  = 1
      stagger       = "15s"
    }

    service {
      name = "frontend"
      port = "http"

      check {
        type     = "tcp"
        interval = "30s"
        timeout  = "10s" 
      }

      tags = [
          "traefik.enable=true",
          "traefik.http.routers.ingress.rule=Host(`hashistack-dc1-fc49215ba4c79ff6.elb.us-east-1.amazonaws.com`)",
          "traefik.http.routers.ingress.entrypoints=http"
      ]
    }          

    task "frontend" {
      driver = "docker"

      config {
        image = "nicholasjackson/fake-service:v0.26.2"
        ports = ["http"]
      }

      env {
        NAME = "frontend"
        UPSTREAM_URIS = "http://middleware.service.consul"
      }

      vault {}

      template {
        data        = <<EOF
{{with secret "secret/data/applications/frontend/config"}}
MESSAGE={{.Data.data.message}}
{{end}}
EOF
        change_mode = "restart"
        destination = "${NOMAD_SECRETS_DIR}/env"
        env         = true
      }

    }
  }
}

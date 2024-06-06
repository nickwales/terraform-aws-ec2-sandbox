job "iis-test" {
  datacenters = ["dc1"]
  type = "service"

  group "iis-test" {
    count = 1

    network {
      port "httplabel" {
        to = 8080
      }
    }

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    task "iis-test" {
      driver = "win_iis"

      config {
        path = "C:\\inetpub\\wwwroot"
        bindings {
          type = "http"
          port = 8080
        }
      }

      template {
        data = <<EOH
NOMAD_APPPOOL_USERNAME=vagrant
NOMAD_APPPOOL_PASSWORD=vagrant
EXAMPLE_ENV_VAR=test12345
EOH

        destination = "secrets/file.env"
        env         = true
      }

      resources {
        cpu    = 100
        memory = 20
      }

      service {
        name = "iis-test"
        port = "httplabel"
      }
    }
  }
}
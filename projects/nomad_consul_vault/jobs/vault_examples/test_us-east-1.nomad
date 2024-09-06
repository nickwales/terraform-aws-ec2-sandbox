
job "test" {

  datacenters = ["dc1"]
  type = "service"

  group "test" {
    count = 1

    task "test" {
      driver  = "exec"
      config {
        command = "sleep"
        args    = ["10000000"]
      }

      identity {
        env  = true
        file = true
        ttl  = "1h"
      } 

      env {
        test = "123444"
      }

      template {
        data = <<EOH
{{ with secret "kv/test" }}
{{ .Data.a }}
{{ end }}
      EOH
        destination   = "${NOMAD_SECRETS_DIR}/secret"
        change_mode   = "restart"
      }          
    }

    vault {
      role = "nomad-workloads"
      file = true
    }
  }
}


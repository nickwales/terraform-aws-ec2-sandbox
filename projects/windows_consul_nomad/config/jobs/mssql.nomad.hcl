job "mssql" {

  datacenters = ["dc1"]
  type = "service"
  namespace = "database"

  constraint {
    attribute = "${attr.kernel.name}"
    value = "windows"
  }

  group "mssql" {
    count = 1

    network {
      port "http" {
        static = 18900
        to     = 18900
      }
    }

    service {
      name = "mssql"
      port = "http"

      check {       
        type     = "tcp"
        name     = "mssql"
        interval = "30s"
        timeout  = "10s"
      }
    }

    task "mssql" {
      driver = "raw_exec"

      artifact {
        source = "https://github.com/nicholasjackson/fake-service/releases/download/v0.26.2/fake_service_windows_amd64.zip"
      }

      config {
        command  = "fake-service.exe"      
      }

      env {
        NAME = "mssql"
        LISTEN_ADDR = "0.0.0.0:18900"
      }

      vault {}

      template {
        data        = <<EOF
{{with secret "secret/data/database/mssql/config"}}
MESSAGE="Instance #{{ env "NOMAD_ALLOC_INDEX"}} - {{.Data.data.message}} - Credential from Vault: {{.Data.data.db_cred}}"
{{end}}
EOF
        change_mode = "restart"
        destination = "${NOMAD_SECRETS_DIR}/config.env"
        env         = true
        splay       = "12s"
      }

    }
  }
}



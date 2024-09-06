variable "hostname" {
  description = "The load balancer hostname"
  type        = string
}

job "aspnet-sample-app" {
  datacenters = ["dc1"]
  type = "service"

  group "app" {
    count = 1
  
    network {
      port "httplabel" {}
    }

    service {
      name = "asp-dot-net"
      port = "httplabel"

      check {
        type     = "tcp"
        interval = "30s"
        timeout  = "5s" 
      }
      tags = [
          "traefik.enable=true",
          "traefik.http.routers.asp.rule=Host(`${var.hostname}`)",
          "traefik.http.routers.asp.entrypoints=asp",          
      ]      
    }  

    task "app" {
      driver = "iis" // The task driver is installed on the windows server

      artifact {
        source = "https://github.com/sevensolutions/nomad-iis/raw/main/examples/aspnet-sample-app.zip"
        destination = "local"
      }

      config {
        application {
          path = "local"
        }
		    
        binding {
          type = "http"
          port = "httplabel"
        }
      }

	    env {
        SAMPLE_KEY = "my-value"
        CONFIG_VARIABLE = "verbose_logging"
      }
    
      resources {
        cpu    = 100
        memory = 150
      }

      template {
        data        = <<EOF
{{with secret "secret/data/default/aspnet-sample-app/config"}}
VAULT_USERNAME="{{.Data.data.username}}"
VAULT_PASSWORD="{{.Data.data.password}}"
VAULT_DB_CRED={{.Data.data.db_cred}}
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
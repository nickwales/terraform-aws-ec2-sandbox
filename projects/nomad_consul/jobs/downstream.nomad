job "downstream" {

  datacenters = ["dc1"]
  type = "service"

  group "downstream" {
    count = 1

    network {
      mode = "bridge"
      port "expose" {}
    }        
    service {
      name = "downstream"
      port = "9090"

      check {
        expose   = "true"
        type     = "http"
        path     = "/"
        interval = "30s"
        timeout  = "5s"
      }

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "midstream"
              local_bind_port  = 8081
            }
          }
        }
      }      
    }          

    task "downstream" {
      driver = "docker"

      config {
        image   = "nicholasjackson/fake-service:v0.26.0"
        ports   = ["http"]
      }

      env {
        UPSTREAM_URIS = "http://127.0.0.1:8081"
      }
      identity {
        # Expose Workload Identity in NOMAD_TOKEN env var poop
        env = false

        # Expose Workload Identity in ${NOMAD_SECRETS_DIR}/nomad_token file
        file = true
      }               
    }
  }
}


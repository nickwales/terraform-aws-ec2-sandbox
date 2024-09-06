job "midstream" {

  datacenters = ["dc1"]
  type = "service"

  group "midstream" {
    count = 1

    network {
      mode = "bridge"
      port "expose" {}
    }        
    service {
      name = "midstream"
      port = "9095"

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
              destination_name = "upstream"
              local_bind_port  = 9092
            }
          }          
        }
      }      
    }          

    task "midstream" {
      driver = "docker"

      config {
        image   = "nicholasjackson/fake-service:v0.26.0"
        ports   = ["http"]
      }

      env {
      #  UPSTREAM_URIS = "http://127.0.0.1:9092"
        MESSAGE = "Midstream"
        LISTEN_ADDR = "0.0.0.0:9095"
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


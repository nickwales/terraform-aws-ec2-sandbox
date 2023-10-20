job "upstream" {

  datacenters = ["dc1"]
  type = "service"

  group "upstream" {
    count = 1

    network {
        port "http" {
          // static = "9090"
          to     = "9091"
        }

    }        
    service {
      name = "upstream"
      port = "9091"

      check {
        type     = "http"
        port     = "http"
        path     = "/"
        interval = "30s"
        timeout  = "5s"
      }

      // connect {
      //   sidecar_service {
      //     proxy {
      //       upstreams {
      //         destination_name = "upstream"
      //         local_bind_port  = 8080
      //       }
      //     }
      //   }
      // }      
    }          

    task "upstream" {
      driver = "docker"

      config {
        image   = "nicholasjackson/fake-service:v0.26.0"
        ports   = ["http"]
      }

      env {
        LISTEN_ADDR = "0.0.0.0:9091"
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


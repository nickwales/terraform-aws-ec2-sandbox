job "teeceepee" {

  datacenters = ["dc1"]
  type = "service"

  group "teeceepee" {
    count = 1

    network {
      mode = "bridge"
      port "expose" {}
    }        
    service {
      name = "teeceepee"
      port = "9095"

      check {
        expose   = "true"
        type     = "http"
        path     = "/"
        interval = "30s"
        timeout  = "5s"
      }

      connect {
        sidecar_service {}
      }      
    }          

    task "teeceepee" {
      driver = "docker"

      config {
        image   = "nicholasjackson/fake-service:v0.26.0"
        ports   = ["http"]
      }

      env {
      #  UPSTREAM_URIS = "http://127.0.0.1:9092"
        MESSAGE = "teeceepee"
        LISTEN_ADDR = "0.0.0.0:9095"
        ERROR_CODE = 200
        poop = true
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


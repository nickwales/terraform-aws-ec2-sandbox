job "upstream" {

  datacenters = ["dc1"]
  type = "service"

  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  group "upstream" {
    count = 1

    network {
      mode = "host"
      port "http" {
        static = 9092
        to     = 9090
      }
    }        

    service {
      name = "upstream"
      port = "http"

      check {
        type     = "tcp"
        interval = "30s"
        timeout  = "5s" 
      }
    }          

    task "upstream" {
      driver = "docker"

      config {
        image = "nicholasjackson/fake-service:v0.26.2"
        ports = ["http"]
      }

      env {
        NAME = "upstream"
        MESSAGE = "Running on Linux"
        UPSTREAM_URIS = "http://service-on-windows.service.consul:9090"
      }                   
    }
  }
}

job "fake-service-linux" {

  datacenters = ["dc1"]
  type = "service"

  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  group "fake-service-linux" {
    count = 1

    network {
      mode = "host"
      port "http" {
        static = 9090
        to     = 9090
      }
    }        

    service {
      name = "service-on-linux"
      port = "http"

      check {
        type     = "tcp"
        interval = "30s"
        timeout  = "5s" 
      }
    }          

    task "fake-service-linux" {
      driver = "docker"

      config {
        image = "nicholasjackson/fake-service:v0.26.2"
        ports = ["http"]
      }

      env {
        NAME = "service-on-linux"
        MESSAGE = "Running on Linux"
        UPSTREAM_URIS = "http://service-on-windows.service.consul:9090"
      }                   
    }
  }
}

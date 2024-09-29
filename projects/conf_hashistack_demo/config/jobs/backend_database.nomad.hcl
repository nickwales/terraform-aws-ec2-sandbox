variable "job_region" {
  type = string
  default = "dc1"
}

variable "partition" {
  type = string
  default = "database"
}

job "backend_database" {

  constraint {
    attribute = "${attr.consul.partition}"
    value     = var.partition
  }

  datacenters = [var.job_region]
  type = "service"

  group "backend" {
    count = 1

    network {
      mode = "bridge"
      port "expose" {}
    }        

    service {
      name = "backend"
      port = "9090"

      check {
        expose   = true
        type     = "http"
        path     = "/health"
        interval = "30s"
        timeout  = "5s"       
      }

      connect {
        sidecar_service {
          proxy {
            transparent_proxy {}
          }
        }  
      }

      meta {
        version = "backend"
      }

      tags = ["backend"]
    }          

    task "backend" {
      driver = "docker"

      config {
        image = "nicholasjackson/fake-service:v0.26.2"
        dns_servers = ["172.17.0.1"]
      }

      env {
        NAME = "Backend in partition: database"
        HEALTH_CHECK_RESPONSE_CODE = 200
       // UPSTREAM_URIS = "http://database.service.test.sg.consul"        
      }                   
    }
  }
}

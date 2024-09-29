variable "job_region" {
  type = string
  default = "dc1"
}

variable "partition" {
  type = string
  default = "default"
}

job "database" {

  datacenters = [var.job_region]
  type = "service"

  constraint {
    attribute = "${attr.consul.partition}"
    value     = var.partition
  }

  group "database" {
    count = 1

    network {
      mode = "bridge"
      port "expose" {}
    }         

    service {
      name = "database"
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
        version = "database"
      }

      tags = ["database"]
    }          

    task "database" {
      driver = "docker"

      config {
        image = "nicholasjackson/fake-service:v0.26.2"
      }

      env {
        NAME = "database in partition: ${var.partition} region: ${var.job_region}"
        HEALTH_CHECK_RESPONSE_CODE = 200
        a = "b"
      }                   
    }
  }
}

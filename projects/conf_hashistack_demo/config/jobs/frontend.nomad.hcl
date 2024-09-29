variable "job_region" {
  type = string
  default = "dc1"
}

variable "partition" {
  type = string
  default = "default"
}

job "frontend" {
  type = "service"

  constraint {
    attribute = "${attr.consul.partition}"
    value     = var.partition
  }

  group "frontend" {
    count = 1

    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }

    network {
      mode = "bridge"
      port "expose" {}
    }        

    service {
      name = "frontend"
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
        version = "frontend"
      }

      tags = ["frontend"]
    }          

    task "frontend" {
      driver = "docker"

      config {
        image = "nicholasjackson/fake-service:v0.26.2"  
        dns_servers = ["172.17.0.1"]
      }

      env {
        NAME = "Frontend in region: ${var.job_region}"
        UPSTREAM_URIS = "http://backend.virtual.consul"

      }                   
    }
  }
}

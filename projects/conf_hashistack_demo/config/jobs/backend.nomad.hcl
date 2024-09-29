variable "job_region" {
  type = string
  default = "dc1"
}

variable "partition" {
  type = string
  default = "default"
}

job "backend" {

  constraint {
    attribute = "${attr.consul.partition}"
    value     = var.partition
  }

  constraint {
    operator  = "distinct_hosts"
    value     = "true"
  }

  datacenters = [var.job_region]
  type = "service"

  group "backend" {
    count = 3

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
        NAME = "Backend in partition: default"
        HEALTH_CHECK_RESPONSE_CODE = 200
        UPSTREAM_URIS = "http://redis.virtual.consul,http://database.service.test.sg.consul"     
      }
      
      template {
        data = <<EOH
NAME="backend in {{env "attr.platform.aws.placement.availability-zone"}} AP: default"
        EOH
        destination = "local/file.stuff"
        env  = true
      }                      
    }
  }
}

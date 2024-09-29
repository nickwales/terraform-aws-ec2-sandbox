variable "job_region" {
  type = string
  default = "dc1"
}

variable "partition" {
  type = string
  default = "default"
}

job "redis" {

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

  group "redis" {
    count = 3

    network {
      mode = "bridge"
      port "expose" {}
    }        

    service {
      name = "redis"
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
        version = "redis"
      }

      tags = ["redis"]
    }          

    task "redis" {
      driver = "docker"

      config {
        image = "nicholasjackson/fake-service:v0.26.2"
        dns_servers = ["172.17.0.1"]
      }

      template {
        data = <<EOH
NAME="redis in {{env "attr.platform.aws.placement.availability-zone"}} AP: default"
        EOH
        destination = "local/file.stuff"
        env  = true
      }
    }
  }
}

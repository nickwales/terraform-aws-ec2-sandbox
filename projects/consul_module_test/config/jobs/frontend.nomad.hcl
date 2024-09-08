job "frontend" {

  datacenters = ["dc1"]
  type = "service"

  group "frontend" {
    count = 2

    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }

    network {
      mode = "bridge"
      port "envoy_admin" {
        to = 19001
      }
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
      
      meta {
        version = "frontend"
      }

      tags = ["frontend"]

      connect {
        sidecar_service {
          proxy {
            transparent_proxy {}              
          }
        }  
      }
    }          

    task "frontend" {
      driver = "docker"

      config {
        image = "nicholasjackson/fake-service:v0.26.2"  
      }

      env {
        NAME = "frontend"
        UPSTREAM_URIS = "http://backend.virtual.consul"
        a = "d"
      }                   
    }
  }
}

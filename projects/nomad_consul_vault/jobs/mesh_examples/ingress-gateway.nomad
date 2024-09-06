job "consul-ingress-gateway" {

  datacenters = ["dc1"]

  # This group provides the service that exists outside of the Consul Connect
  # service mesh. It is using host networking and listening to a statically
  # allocated port.
 
  group "consul-ingress-gateway" {

    count = 2

    network {
      mode = "bridge"
      
      port "downstream" {
        static = 8080
        to   = 8080
      }
      port "teeceepee" {
        static = 8081
        to   = 8081
      }      
    }

    service {
      name = "consul-ingress-gateway"

      connect {
        gateway {

          proxy {}
          ingress {
            tls {
              enabled = true
              tls_min_version = "TLSv1_2"
              tls_max_version = "TLSv1_2"
            }
            listener {
              port     = 8080
              protocol = "http"
              service {
                name = "downstream"
                hosts = ["nomad-consul-dc1-600b96bb9c4f4275.elb.us-east-1.amazonaws.com"]
              }
              
            } 
            listener {
              port     = 8081
              protocol = "tcp"
              service {
                name = "teeceepee"
              }
            }                        
          }
        }
      }
    }
  }
}

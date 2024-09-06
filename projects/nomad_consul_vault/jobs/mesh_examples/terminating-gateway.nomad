job "countdash-terminating" {

  datacenters = ["dc1"]

  # This group provides the service that exists outside of the Consul Connect
  # service mesh. It is using host networking and listening to a statically
  # allocated port.
 
  group "gateway" {
    network {
      mode = "bridge"
    }

    service {
      name = "api-gateway"

      connect {
        gateway {
          # Consul gateway [envoy] proxy options.
          proxy {
            # The following options are automatically set by Nomad if not explicitly
            # configured with using bridge networking.
            #
            # envoy_gateway_no_default_bind = true
            # envoy_gateway_bind_addresses "default" {
            #   address = "0.0.0.0"
            #   port    = <generated listener port>
            # }
            # Additional options are documented at
            # https://www.nomadproject.io/docs/job-specification/gateway#proxy-parameters
          }

          # Consul Terminating Gateway Configuration Entry.
          terminating {
            # Nomad will automatically manage the Configuration Entry in Consul
            # given the parameters in the terminating block.
            #
            # Additional options are documented at
            # https://www.nomadproject.io/docs/job-specification/gateway#terminating-parameters
            service {
              name = "upstream"
            }
          }
        }
      }
    }
  }
}

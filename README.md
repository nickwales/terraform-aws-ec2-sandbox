### Consul Appliance

This is a deployment of a fully featured Consul cluster on a VM

A single node server
Ingress, Terminating and Mesh Gateways

### How to deploy

Run the terraform! The two ubuntu servers will be deployed as dc1 and dc2.

They will now be in a state to be peered, using the UI is the preferred method here which is available on port 8500 on each server. (See outputs for public IP addresses)

### Examples

In the deploy directory is a range of different activities. These have scripts to be run on the datacenter appropriate instances. 


### Adding external services

If there are additional services outside the cluster that need to be monitored and added to the mesh we need to
1. Register the service

Update the `templates/registration_template.json` appropriately then run

`curl --header 'X-Consul-Token: root' --data @templates/registration_template.json http://<CONSUL_HTTP_ADDR>:8500/v1/catalog/register`

2. Add it to the terminating gateway

```
cat <<EOT > ./terminating.hcl
Kind = "terminating-gateway"
Name = "terminating-gateway"

Services = [
  {
    Name = "<name_of_service>"
  }
]
EOT

consul config write ./terminating.hcl
```


3. Enable intentions

```
cat <<EOT > intention.hcl
Kind = "service-intentions"
Name = "<name_of_service>"
Sources = [
  {
    Name   = "ingress-gateway"
    Action = "allow"
  },
  {
    Name   = "ingress-gateway"
    Peer   = "dc1"
    Action = "allow"
  },
  {
    <add more peers as appropriate>
  }
]
EOT

consul config write ./intention.hcl
```

4. Create a resolution rule on the downstream (where the request originates) cluster.

```
cat <<EOT > legacy-resolver.hcl
Kind           = "service-resolver"
Name           = "<name_of_service>"
ConnectTimeout = "5s"
Failover = {
  "*" = {
    Targets = [
      {Peer = "dc2"}
    ]
  }
}
EOT
consul config write ./legacy-resolver.hcl
```


5. Configure the ingress 

```
cat <<EOT > /root/ingress.hcl
Kind = "ingress-gateway"
Name = "ingress-gateway"

Listeners = [
  {
    Port     = 8080
    Protocol = "tcp"
    Services = [
      {
        Name = "<name_of_service_from_service_resolver>"
      }
    ]
  }
]
EOT

consul config write ./ingress.hcl
```

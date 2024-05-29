### Install AWS Ingress Controller

```
helm repo add eks https://aws.github.io/eks-charts
helm repo update eks
```

### Create independent K8s clusters

## DC1
```

terraform -chdir=dc1 init
terraform -chdir=dc1 apply -auto-approve

aws eks update-kubeconfig --region us-east-1 --name cluster_dc1 --alias dc1
```

# Install Consul
`consul-k8s install -f helm/dc1.yaml`


## Post deployment
```
kubectl apply -f config/mesh/mesh-gateway.yaml -n consul
kubectl apply -f config/proxy-defaults/global.yaml -n consul
kubectl apply -f config/ingress/ingress-dc1.yaml -n consul

kubectl apply -f config/apps/frontend.yaml 
kubectl apply -f config/intentions/frontend.yaml
kubectl apply -f config/apps/api.yaml 
kubectl apply -f config/intentions/api.yaml
kubectl apply -f config/exported-services/dc1.yaml
```

## DC2

```
terraform -chdir=dc2 init
terraform -chdir=dc2 apply -auto-approve

aws eks update-kubeconfig --region us-east-1 --name cluster_dc2a --alias dc2


# Install Consul
consul-k8s install -f helm/dc2.yaml

kubectl apply -f config/mesh/mesh-gateway.yaml -n consul
kubectl apply -f config/proxy-defaults/global.yaml -n consul
kubectl apply -f config/mesh/mesh-gateway.yaml -n consul
```

## Deploy an app deployment
```
kubectl apply -f config/apps/backend.yaml 
kubectl apply -f config/intentions/backend.yaml 
kubectl apply -f config/exported-services/dc2.yaml
```


## Private links

Setup a private endpoint in each VPC pointing to the mesh gateway NLB.

Setup an endpoint in each VPC that points to the opposite private endpoint in the private subnet.
Add a security group that allows port 443 (https) access from the private subnet to the endpoint.

Accept the peering requests from the private endpoints. 


## Peer Consul

We will generate the token from DC2

# Get the DC2 ACL token:
`dc2_token=$(kubectl get -n consul secrets/consul-bootstrap-acl-token --template={{.data.token}} | base64 -D)`

# Get the endpoint addresses and apply them to the mesh gateways

This address is available from the UI. The endpoint in dc1 needs to be updated as the WAN address for dc2 and vice versa.

The helm chart should look similar to this:

```
meshGateway:
  enabled: true
  replices: 2
  wanAddress:
    source: Static
    static: vpce-048f7ae0f9adee4fe-hxj7h45m.vpce-svc-0051407bb63dfe3f5.us-east-1.vpce.amazonaws.com
```



# Create port-forwarding for dc1 and create the token

`kubectl port-forward -n consul service/consul-ui 8500:443`

Open a browser at: `https://localhost:8500` login using the output from:

`kubectl get -n consul secrets/consul-bootstrap-acl-token --template={{.data.token}} | base64 -D)`

Browse to peers -> Add peer connection

Name of Peer = dc2 (the other datacenter)

Click Generate Token, copy the token.

# Establishing the peering connection

`kubectl config use-context dc2`
`kubectl port-forward -n consul service/consul-ui 8501:443`

Open a browser at: `https://localhost:8501` login using the output from:

`kubectl get -n consul secrets/consul-bootstrap-acl-token --template={{.data.token}} | base64 -D)`

Browse to peers -> Add peer connection -> Establish peering

Name of Peer = `dc1` 

Paste the token from dc1 and click `Add peer`

 
# See the services working
```
kubectl config use-context dc1

kubectl -n consul get svc 
```

Copy the EXTERNAL-IP address for the `consul-ingress-gateway`

In a browser paste the address in and add port 8080.

You should see a request for the frontend in DC1 call the backend in DC2 which subsequently calls the API back in DC1, we have bi-directional traffic flows :hurrah:.  


## Consul DNS Views 

Instructions

### Create certs
```
consul tls ca create
mkdir certs
mv *.pem certs/
```

### Create the cluster

```
terraform init -upgrade
terraform apply -auto-approve
```

### Configure kubectl

```
aws eks update-kubeconfig --region us-east-1 --name lambda_k8s
```

### Create the consul namespace and deploy certificates
```
kubectl create namespace consul

kubectl create secret -n consul generic consul-agent-ca \
  --from-file='tls.crt=./certs/consul-agent-ca.pem'

kubectl create secret -n consul generic consul-agent-ca-key \
  --from-file='tls.key=./certs/consul-agent-ca-key.pem'
```

### Deploy Consul using the helm chart.

Until fully released we need to checkout the main branch of the consul-k8s project and specify the location in the helm command:

```
consul-k8s install -f helm/values.yaml #-auto-approve
```

### Configure CoreDNS

#### Get the cluster IP of the dns proxy
```
kubectl get svc consul-dns-proxy -n consul -o jsonpath='{.spec.clusterIP}'
```

#### Update CoreDNS configmap
https://developer.hashicorp.com/consul/docs/k8s/dns#coredns-configuration
```
kubectl edit configmap coredns --namespace kube-system
```

The configmap should look like the below with the addition of the consul section
```
data:
  Corefile: |
    .:53 {
        errors
        health
        kubernetes cluster.local in-addr.arpa ip6.arpa {
          pods insecure
          fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }
    consul:53 {
      errors
      cache 30
      forward . <consul-dns-proxy-from-above>
      reload
    }
```

### Deploy the applications

```
kubectl apply -f apps/frontend.yaml
kubectl apply -f apps/api.yaml
```

### Inspect the frontend

```
kubectl  port-forward svc/frontend 9090:9090
```

Open your browser to `http://localhost:9090/ui/` 







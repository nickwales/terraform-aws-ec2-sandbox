## Datadog Installation

helm repo add datadog https://helm.datadoghq.com
helm repo update
kubectl create secret generic datadog-secret --from-literal api-key=<DD_API_KEY>

helm install datadog-agent -f datadog-values.yaml datadog/datadog


## Consul

helm repo add hashicorp https://helm.releases.hashicorp.com
helm install consul hashicorp/consul --set global.name=consul --create-namespace --namespace consul --values helm/consul.yaml


## Debug

/opt/datadog-agent/bin/agent/agent status

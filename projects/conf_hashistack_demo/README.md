#### Nomad / Consul HashiConf 2024 Demo

This project deploys Nomad and Consul clusters to showcase the tight integration between the two.

Highlights include 
- The API gateway 
- Use of the transparent proxy 
- Sameness groups to provide failover for the database
- Locality aware routing. The backend will only mkae requests to a local redis instance. 
- 


### Deploying 

This project includes two sections. 

## Infrastructure

This creates the cloud infrastructure, and Nomad + Consul clusters
- Consul server ASG
- Nomad server ASG
- Nomad clients deployed into two Consul admin partitions.

This should be created with the `./deploy_infra.sh` command.


## Configuration

This deploys Nomad jobs and Consul configurations with 
- An HTTP listener and routing for the API Gateway.
- Frontend, Backend, Redis and Database services.


This should be run after the infrastructure is deployed and available with `./post_deploy.sh`.

### Undeploying

Use the `./undeploy.sh` script to tear everything down.
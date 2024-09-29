#### Nomad / Consul HashiConf 2024 Demo

This project deploys Nomad and Consul clusters to showcase the tight integration between the two.

Highlights include 
- The API gateway provides the entrypoint to our mesh services.
- Use of the transparent proxy for all connectivity, `<service>.virtual.consul`.
- Sameness groups to provide automatic discovery of the database in another partition
- Locality aware routing. The backend will default to making requests to a redis instance in the same AZ.


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
- Intentions
- Locality configuration for the backend

This should be run after the infrastructure is deployed and available with `./post_deploy.sh`.

### Undeploying

Use the `./undeploy.sh` script to tear everything down.

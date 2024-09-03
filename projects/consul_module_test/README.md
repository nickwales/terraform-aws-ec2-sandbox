#### Testing Consul ACL Management with Vault Agent

This project includes two sections. 

## Infrastructure

This creates a Consul cluster on AWS with
- Consul server ASG
- Consul Gateway ASG (API, Ingress, Mesh, Terminating)
- A mesh task ASG

This should be created with the `./deploy_infra.sh` command.


## Configuration

This configures Consul with 
- service defaults for the mesh task
- An HTTP listener and routing for the API Gateway.

This should be run after the infrastructure is deployed with `./post_deploy.sh`.


Use the `./undeploy.sh` script to tear everything down.
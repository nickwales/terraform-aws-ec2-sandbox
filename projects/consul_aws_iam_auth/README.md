#### Consul AWS IAM Auth 

This project deploys a Consul server and configures it for AWS IAM Auth from clients.


### Deplyment notes

Deploy the infrastructure with `./deploy_infra.sh`

Update `config/terraform.tfvars` with a list of roles to enable authentication for.
Configure `config/auth_methods.tf` with IAM and Consul roles to enable appropriate access levels.

When Consul is deploy the configurations with `./post_deploy.sh` 


### Usage

## Using the Consul agent
Currently the consul agent can be used to login. With the `-aws-auto-bearer-token` option the signed request can be created automatically.

Running `./login_agent.sh` will attempt login and create `./token` with the newly created credential.


## Direct to the API

`./login_api.sh` is a work in progress. 

Examples of the signing process are available [here](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_sigv.html#reference_aws-signing-resources) and in Consul [here](https://github.com/hashicorp/consul/blob/main/command/login/aws.go).

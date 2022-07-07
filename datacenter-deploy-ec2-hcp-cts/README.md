# Consul-terraform-sync example

## Description

The Terraform code in the subfolders contained here deploys the following:

### 1-vpc-hcp

- An AWS VPC
- An HCP HVN virtual network
- An HCP Consul cluster
- A peering between the VPC and the HCP

### 2-ec2-consul-client-cts
- An EC2 instance:
    - Ubuntu Linux 18.04
    - Consul client connecting to the HCP Consul cluster
    - Consul-terraform-sync binary installed 
    - HashiCorp example services (_counting_,_dashboard_) binaries installed

## Prerequisites

In order to use these , please install:

- Terraform
- AWS CLI

Then set up your shell environment with the following variables:

- AWS_ACCESS_KEY_ID - your AWS access key ID
- AWS_SECRET_ACCESS_KEY - your AWS secret access key
- AWS_SESSION_TOKEN - your AWS session token
- HCP_CLIENT_ID - your HCP service principal client ID 
- HCP_CLIENT_SECRET - your HCP service principal client secret 

## Deployment

First deploy the base infrastructure.

```shell
cd 1-vpc-hcp
terraform init
terraform apply
```

Then prepopulate the correct values for Terraform in the `2-ec2-consul-client-cts` folder and run the deployment.

```shell
echo "vpc_id=\"$(terraform output -raw vpc_id)\"\nvpc_cidr_block=\"$(terraform output -raw vpc_cidr_block)\"\nsubnet_id=\"$(terraform output -raw subnet_id)\"\ncluster_id=\"$(terraform output -raw hcp_consul_cluster_id)\"\nhcp_consul_security_group_id=\"$(terraform output -raw hcp_consul_security_group)\"" > ../2-ec2-consul-client-cts/terraform.tfvars
cd ../2-ec2-consul-client-cts
terraform apply
```

Once ready, you can access your EC2 instance by the following command in the `2-ec2-consul-client-cts` folder

```shell
ssh ubuntu@$(terraform output -raw ec2_client) -i ./consul-client.pem 
```

## Credits

This work is a modification of the `datacenter-deploy-ec2-hcp` scenario in the same repository.

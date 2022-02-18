1. Set environmental variables.

```sh
export AWS_ACCESS_KEY_ID="your-aws-access-key-id"
export AWS_SECRET_ACCESS_KEY="your aws-secret-key"
export HCP_CLIENT_ID="your-hcp-client-id"
export HCP_CLIENT_SECRET="your-hcp-client-secret"
```

2. Run Terraform

```sh
terraform init
```

```sh
terraform apply --auto-approve
```

3. Go through the [EKS + HCP Consul tutorial](https://learn.hashicorp.com/tutorials/cloud/consul-client-eks)
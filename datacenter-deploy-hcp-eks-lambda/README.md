# Consul API Gateway on EKS + HCP

## Overview

Terraform will perform the following actions:
- Create VPC and HVN networks
- Peer VPC and HVN networks
- Create HCP Consul cluster
- Create EKS cluster
- Deploy API GW CRDs to EKS
- Deploy Consul + API GW controller to EKS

You will perform these steps:
- Deploy Hashicups & Echo services to EKS
- Deploy remaining API GW resources (gateway.yaml & routes.yaml) to EKS
- Verify AWS Load Balancer is created once API GW is deployed
- Verify access behavior with Hashicups via API GW
- Verify load balancing behavior with Echo Servers via API GW
- Clean up environment

## Steps

1. Clone repo
2. `cd datacenter-deploy-hcp-eks-lambda`
3. Set credential environment variables for AWS and HCP
    1. 
    ```shell
    export AWS_ACCESS_KEY_ID="YOUR_AWS_ACCESS_KEY"
    export AWS_SECRET_ACCESS_KEY="YOUR_AWS_SECRET_KEY"
    export HCP_CLIENT_ID="YOUR_HCP_CLIENT_ID"
    export HCP_CLIENT_SECRET="YOUR_HCP_SECRET"
    ```
4. `cd terraform`
5. Run Terraform (resource creation will take ~15 minutes to complete)
    1. `terraform init`
    2. `terraform apply`
6. Configure `kubectl` to communicate with your EKS cluster
    1. `aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw kubernetes_cluster_id)` 
7. Deploy HashiCups
    1. `kubectl apply --filename ../hashicups`

[//]: # (8. Create API Gateway and respective route resources)

[//]: # (    1. `kubectl apply --filename ../api-gw/consul-api-gateway.yaml && kubectl wait --for=condition=ready gateway/api-gateway --timeout=90s && kubectl apply --filename ../api-gw/routes.yaml` )
9. Locate the external IP for your API Gateway
    1. `kubectl get services api-gateway`
10.  Visit the following urls in the browser to verify HashiCups deployed successfully.
11. Confirm `public-api` routes traffic to `payments` service
    1. `kubectl port-forward deploy/public-api 8080`
    2. 
    ```shell
    curl 'http://localhost:8080/api' \
      -H 'Accept-Encoding: gzip, deflate, br' \
      -H 'Content-Type: application/json' \
      -H 'Accept: application/json' \
      -H 'Connection: keep-alive' \
      -H 'DNT: 1' \
      -H 'Origin: http://localhost:8080' \
      --data-binary '{"query":"mutation{ pay(details:{ name: \"nic\", type: \"mastercard\", number: \"1234123-0123123\", expiry:\"10/02\",    cv2: 1231, amount: 12.23 }){id, card_plaintext, card_ciphertext, message } }"}' --compressed | jq
      ```
12. Uncomment `lambda-registrator.tf` and re-apply Terraform to deploy the lambda register.
    1. ` terraform init && terraform apply`
13. Uncomment `payments-lambda.tf` and re-apply Terraform to deploy the `payments-lambda` Lambda function.
    1. `terraform apply`
14. Give terminating gateway ACL token the ability to grant `service:write` for all linked services. ([GitHub Issue](https://github.com/hashicorp/consul/issues/12116#issuecomment-1019463753)) (add to beginning of policy)
    1. 
    ```shell
    service "payments" {
      policy = "write"
      intentions = "read"
    }

    service "payments-lambda" {
      policy = "write"
      intentions = "read"
    }
    ```
15. Create terminating gateway
    1. `kubectl apply --filename ../terminating-gateway-lambda-payments.yaml` 
16. Create service splitter to route traffic to lambda function.
    1. `kubectl apply --filename ../service_splitter.yaml` 
17. Create service intention from `public-api` to `payments-lambda`.
18. Confirm `public-api` routes traffic to `payments` service
    1. `kubectl port-forward deploy/public-api 8080`
    2. 
    ```shell
    curl 'http://localhost:8080/api' \
      -H 'Accept-Encoding: gzip, deflate, br' \
      -H 'Content-Type: application/json' \
      -H 'Accept: application/json' \
      -H 'Connection: keep-alive' \
      -H 'DNT: 1' \
      -H 'Origin: http://localhost:8080' \
      --data-binary '{"query":"mutation{ pay(details:{ name: \"nic\", type: \"mastercard\", number: \"1234123-0123123\", expiry:\"10/02\",    cv2: 1231, amount: 12.23 }){id, card_plaintext, card_ciphertext, message } }"}' --compressed | jq
      ```
19. Clean up
    1. Destroy all Kubernetes resources (need to provide explicit steps to remove CRDs + HashiCups, and remove Consul -- if you skip this step, you need to run terraform destroy twice to completely destroy.)
    2. Destroy Terraform resources
      `terraform destroy`

## Common errors

If you experience a 503 error trying to reach the Lambda function, ensure that you updated your terminating gateway ACL token policy to allow traffic to your **Lambda** service. If your policy is properly defined, wait a minute before trying again. The 503 error may be due to `no healthy upstream errors`. This means that the Lambda function wasn't available (most likely due to cold start).

If you experience a 403 error, this is likely due to a RBAC (permissions/service intentions) issue. Ensure that you have an intention that allows traffic from `public-api` to `payments-lambda`.

To debug and view the error messages, view the `public-api` logs.

```
kubectl logs deploy/public-api public-api
```

# 1. Initialize

```
terraform init
```

# 2. Deploy infrastructure
This includes HCP Consul and EKS. It also includes installing Consul on EKS.

```
terraform apply
```

# 3. Update kubeconfig

```
eval $(terraform output -raw eks_update_kubeconfig_command)
```

# 4. Set up AWS env vars

```
export AWS_REGION=$(terraform output -raw region)  && \
export LOG_GROUP="$(terraform output -json cloudwatch_logs_path | jq -r '.registrator')"
```

# 5. Configure Consul CLI

```
export CONSUL_HTTP_TOKEN=$(terraform output -raw hcp_login_token) && \
export CONSUL_HTTP_ADDR=$(terraform output -raw consul_addr) && \
export POLICY_NAME="payments-lambda-tgw"
```

# 6. Deploy HashiCups

```
kubectl apply -f ./modules/eks-client/hashicups/kube_resources/config-map && \
kubectl apply -f ./modules/eks-client/hashicups/kube_resources/service-account && \
kubectl apply -f ./modules/eks-client/hashicups/app/nginx && \
kubectl apply -f ./modules/eks-client/hashicups/app/frontend && \
kubectl apply -f ./modules/eks-client/hashicups/app/public-api && \
kubectl apply -f ./modules/eks-client/hashicups/app/product-api && \
kubectl apply -f ./modules/eks-client/hashicups/app/product-api-db && \
kubectl apply -f ./modules/eks-client/hashicups/app/payments
```

# 7. Deploy Consul HashiCups resources

```
kubectl apply -f ./modules/eks-client/hashicups/consul_resources/proxy-defaults && \
kubectl apply -f ./modules/eks-client/hashicups/consul_resources/service-defaults && \
kubectl apply -f ./modules/eks-client/hashicups/consul_resources/service-intentions
```

# 8. Deploy API Gateway

API Gateway CRDs were installed in the `terraform apply` step.

```
kubectl apply -f ./modules/eks-client/api-gw/consul-api-gateway.yaml && \
kubectl wait --for=condition=ready gateway/api-gateway --timeout=90s && \
kubectl apply -f ./modules/eks-client/api-gw/routes.yaml
```

## Verify API Gateway deployment

```
kubectl get services api-gateway
```

## Verify payment service routing to Kubernetes

```
kubectl port-forward deploy/public-api 8080
```

```
curl -v 'http://localhost:8080/api' \
	-H 'Accept-Encoding: gzip, deflate, br' \
	-H 'Content-Type: application/json' \
	-H 'Accept: application/json' \
	-H 'Connection: keep-alive' \
	-H 'DNT: 1' \
	-H 'Origin: http://localhost:8080' \
	--data-binary '{"query":"mutation{ pay(details:{ name: \"HashiCups_User!\", type: \"mastercard\", number: \"1234123-0123123\", expiry:\"10/02\",    cv2: 1231, amount: 12.23 }){id, card_plaintext, card_ciphertext, message } }"}' --compressed | jq
```

##
## Lamdba portion
##

# 9. Deploy Lambda Registrator

Create file named `lambda-tutorial.tf` with the following contents.

```
module "lambda-registration" {
  source                    = "hashicorp/consul-lambda-registrator/aws//modules/lambda-registrator"
  version                   = "0.1.0-beta1"
  name                      = aws_ecr_repository.lambda-registrator.name
  ecr_image_uri             = "${aws_ecr_repository.lambda-registrator.repository_url}:${local.ecr_image_tag}"
  subnet_ids                = module.infrastructure.vpc_subnets_lambda_registrator
  security_group_ids        = [module.infrastructure.vpc_default_security_group]
  sync_frequency_in_minutes = 1

  consul_http_addr       = module.infrastructure.consul_addr
  consul_http_token_path = aws_ssm_parameter.token.name

  depends_on = [
    null_resource.push-lambda-registrator-to-ecr
  ]
}

resource "aws_ecr_repository" "lambda-registrator" {
  name = local.ecr_repository_name
}

resource "null_resource" "push-lambda-registrator-to-ecr" {
  triggers = {
    ecr_base_image = local.ecr_base_image
  }

  provisioner "local-exec" {
    command = <<EOF
    aws ecr get-login-password --region ${local.public_ecr_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.lambda-registrator.repository_url}
    docker pull ${local.ecr_base_image}
    docker tag ${local.ecr_base_image} ${aws_ecr_repository.lambda-registrator.repository_url}:${local.ecr_image_tag}
    docker push ${aws_ecr_repository.lambda-registrator.repository_url}:${local.ecr_image_tag}
    EOF
  }

  depends_on = [
    aws_ecr_repository.lambda-registrator
  ]
}

resource "aws_ssm_parameter" "token" {
  name  = "/${local.ecr_repository_name}/token"
  type  = "SecureString"
  value = module.infrastructure.consul_token
  tier  = "Advanced"
}
```

```
terraform get
```

```
terraform apply
```

# 10. Deploy Lambda Payments Service

Add the following to `lambda-tutorial.tf`.

```
resource "aws_lambda_function" "lambda-payments" {
	filename         = local.lambda_payments_path
	source_code_hash = filebase64sha256(local.lambda_payments_path)
	function_name    = local.lambda_payments_name
	role             = aws_iam_role.lambda_payments.arn
	handler          = "lambda-payments"
	runtime          = "go1.x"
	tags = {
		"serverless.consul.hashicorp.com/v1alpha1/lambda/enabled"          = "true"
		"serverless.consul.hashicorp.com/alpha/lambda/payload-passthrough" = "true"
		"serverless.consul.hashicorp.com/alpha/lambda/invocation-mode"     = "ASYNCHRONOUS"
	}
}

resource "aws_iam_policy" "lambda_payments" {
	name        = "${local.lambda_payments_name}-policy"
	path        = "/"
	description = "IAM policy lambda payments"

	policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Action": [
				"logs:CreateLogGroup",
				"logs:CreateLogStream",
				"logs:PutLogEvents"
			],
			"Resource": "arn:aws:logs:*:*:*",
			"Effect": "Allow"
		}
	]
}
EOF
}

resource "aws_iam_role" "lambda_payments" {
	name = "${local.lambda_payments_name}-role"

	assume_role_policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Action": "sts:AssumeRole",
			"Principal": {
				"Service": "lambda.amazonaws.com"
			},
			"Effect": "Allow",
			"Sid": ""
		}
	]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_payments" {
	role       = aws_iam_role.lambda_payments.name
	policy_arn = aws_iam_policy.lambda_payments.arn
}
```

```
terraform apply
```

## Verify Lambda registration

```
aws logs filter-log-events --region $AWS_REGION --log-group-name $LOG_GROUP  --filter-pattern "Upserting" | jq '.events[].message'
```

# 11. Create terminating gateway policy

```
TGW_TOKEN=$(consul acl token list -format=json | jq '.[] | select(.Roles[]?.Name | contains("terminating-gateway"))' | jq -r '.AccessorID') && echo $TGW_TOKEN
```

```
consul acl policy create -name "${POLICY_NAME}" -description "Allows Terminating Gateway to pass traffic from the payments Lambda function" -rules @./practitioner/terminating-gateway-policy.hcl
```

```
consul acl token update -id $TGW_TOKEN -policy-name $POLICY_NAME -merge-policies -merge-roles
```

# 12. Deploy Terminating Gateway

```
kubectl apply --filename ./practitioner/terminating-gateway.yaml
```

# 13. Route traffic to lambda

```
kubectl apply -f ./practitioner/service-intentions.yaml
kubectl apply -f ./practitioner/service-splitter.yaml
```

## Verify routed traffic 

```
kubectl port-forward deploy/public-api 8080
```

```
curl -v 'http://localhost:8080/api' \
	-H 'Accept-Encoding: gzip, deflate, br' \
	-H 'Content-Type: application/json' \
	-H 'Accept: application/json' \
	-H 'Connection: keep-alive' \
	-H 'DNT: 1' \
	-H 'Origin: http://localhost:8080' \
	--data-binary '{"query":"mutation{ pay(details:{ name: \"HELLO_LAMBDA_FUNCTION!\", type: \"mastercard\", number: \"1234123-0123123\", expiry:\"10/02\",    cv2: 1231, amount: 12.23 }){id, card_plaintext, card_ciphertext, message } }"}' --compressed | jq
```

Search for Lambda transaction

```
export LAMBDA_FUNC_LOG=$(terraform output -json | jq -r '.cloudwatch_logs_path.value.payments')
aws logs filter-log-events --region $AWS_REGION --log-group-name $LAMBDA_FUNC_LOG | jq '.events[].message'
```

# Destroy

```
terraform destroy
```
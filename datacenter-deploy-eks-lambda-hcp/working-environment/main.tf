locals {
  public_ecr_region   = "us-west-2"
  lambda_log_group    = "/aws/lambda/${local.ecr_repository_name}"
  ecr_base_image      = "public.ecr.aws/hashicorp/consul-lambda-registrator:0.1.0-alpha2"
  ecr_repository_name = "lambda_registrator-${var.identifier}"
  ecr_image_tag       = "0.1.0-beta1"
}

# Creates the resources in Kubernetes for the reader to use their working environment
module "kubernetes_resources" {
  source = "../modules/kubernetes"

  cluster_service_account_name = var.cluster_service_account_name
  consul_accessor_id           = var.consul_accessor_id
  consul_ca                    = var.consul_ca
  consul_config                = var.consul_config
  consul_http_addr             = var.consul_http_addr
  consul_http_token            = var.consul_http_token
  consul_secret_id             = var.consul_secret_id
  kube_context                 = var.kube_context
  role_arn                     = var.role_arn
  profile_name                 = var.profile_name
  cluster_name                 = var.cluster_name
  cluster_region               = var.cluster_region
  consul_gossip_key            = var.gossip_key
  kube_cluster_endpoint        = var.kube_cluster_endpoint
  working-pod-service_account  = var.cluster_service_account_name
  working-pod-name             = var.pod_name
  consul_datacenter            = var.consul_datacenter
  kube_cluster_ca              = var.kube_cluster_ca
  kubeconfig                   = var.kubeconfig
  kube_ctx_alias               = var.kube_ctx_alias
  log_group                    = local.lambda_log_group
  identifier                   = var.identifier
}


locals {
  ecr_uri             =  "${aws_ecr_repository.lambda-registrator.repository_url}:${local.ecr_image_tag}"
  ssm_token_path      =   "/${local.ecr_repository_name}-${var.identifier}/token"
  registrator_version = "0.1.0-beta1"
}

# Create ECR Repository in account
resource "aws_ecr_repository" "lambda-registrator" {
  name = local.ecr_repository_name
}

resource "aws_ssm_parameter" "token" {
  name  = local.ssm_token_path
  type  = var.ssm_type
  value = var.consul_http_token
  tier  = var.ssm_tier
}

resource "null_resource" "push-lambda-registrator-to-ecr" {
  triggers = {
    ecr_base_image = local.ecr_base_image
    region         = local.public_ecr_region
    image_tag      = local.registrator_version
    repository     = local.ecr_repository_name
  }

  provisioner "local-exec" {
    command = <<EOF
    aws ecr get-login-password --region ${local.public_ecr_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.lambda-registrator.repository_url}
    docker pull ${local.ecr_base_image}
    docker tag ${local.ecr_base_image} ${aws_ecr_repository.lambda-registrator.repository_url}:${local.ecr_image_tag}
    docker push ${aws_ecr_repository.lambda-registrator.repository_url}:${local.ecr_image_tag}
    EOF
  }

  provisioner "local-exec" {
    when = destroy
    # Remove image from ECR during the removal of resources. Terraform doesn't manage this resource directly.
    command = "aws ecr batch-delete-image --region ${self.triggers.region} --repository-name ${self.triggers.repository} --image-ids imageTag=${self.triggers.image_tag}"

  }

  depends_on = [
    aws_ecr_repository.lambda-registrator
  ]
}


module "lambda-registration" {
  source                    = "hashicorp/consul-lambda-registrator/aws//modules/lambda-registrator"
  version                   = "0.1.0-beta1"
  name                      = aws_ecr_repository.lambda-registrator.name
  ecr_image_uri             = local.ecr_uri
  subnet_ids                = var.vpc_subnets
  security_group_ids        = [var.vpc_security_group_id]
  sync_frequency_in_minutes = 1

  consul_http_addr       = var.consul_public_endpoint
  consul_http_token_path = aws_ssm_parameter.token.name

  depends_on = [
    null_resource.push-lambda-registrator-to-ecr
  ]
}


## Part Two

data "archive_file" "lambda_zip_inline" {
 type = "zip"
 output_path = "./function.zip"
 source {
  content = <<EOF
def handler(event, context):
    return "<h3>Currently down for maintenance</h3>"
  EOF
  filename = "main.py"
  }
}

resource "aws_lambda_function" "frontend-maintenance" {
  filename = data.archive_file.lambda_zip_inline.output_path
  source_code_hash = data.archive_file.lambda_zip_inline.output_base64sha256
  role = aws_iam_role.lambda_payments.arn
  function_name = "frontend-lambda-${var.identifier}"
  handler = "main.handler"
  runtime = "python3.9"
  tags = {
    "serverless.consul.hashicorp.com/v1alpha1/lambda/enabled"          = "true"
    "serverless.consul.hashicorp.com/alpha/lambda/payload-passthrough" = "true"
    "serverless.consul.hashicorp.com/alpha/lambda/invocation-mode"     = "ASYNCHRONOUS"
  }

}

resource "aws_iam_policy" "lambda_payments" {
  name        = "lambda-frontend-${var.identifier}"
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
  name = "lambda-frontend-${var.identifier}"

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

#resource "null_resource" "testing" {
#  provisioner "local-exec" {
#    command = <<EOF
#    export KUBECONFIG=$HOME/.kube/tutorial_config
#    export POD=$(kubectl get pods -l app=tutorial  -o json | jq -r ".items[0].metadata.name")
#    kubectl exec $POD -c tutorial -- kubectl apply --filename /kube-crds/terminatinggateway-frontend-lambda.yaml
#    kubectl exec $POD -c tutorial -- consul acl policy create -name "frontend-lambda-tgw" -description "Allows Terminating Gateway to pass traffic from the frontend Lambda function" -rules @/kube-crds/lambda-frontend.hcl
#    kubectl exec $POD -c tutorial -- export POLICY_NAME="frontend-lambda-tgw" && \
#      export POLICY_NAME="frontend-lambda-tgw" && \
#      TGW_TOKEN=$(consul acl token list -format=json | jq '.[] | select(.Roles[]?.Name | contains("terminating-gateway"))' | jq -r '.AccessorID') && \
#      consul acl token update -id $TGW_TOKEN -policy-name $POLICY_NAME && \
#      kubectl apply --filename /kube-crds/servicesplitter-frontend-lambda.yaml
#    EOF
#  }
#  depends_on = [module.kubernetes_resources]
#}
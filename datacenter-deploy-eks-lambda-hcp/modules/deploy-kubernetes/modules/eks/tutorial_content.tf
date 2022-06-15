data "aws_caller_identity" "current" {}

# Create ECR Repository in account
resource "aws_ecr_repository" "lambda-registrator" {
  name = var.ecr_config.ecr_repository_name
}


# Push to ECR
resource "null_resource" "push-lambda-registrator-to-ecr" {
  triggers = {
    ecr_base_image = var.ecr_config.ecr_base_image
  }

  provisioner "local-exec" {
    command = <<EOF
    aws ecr get-login-password --region ${var.ecr_config.public_ecr_region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.eks_config.aws_region}.amazonaws.com
    docker pull ${var.ecr_config.ecr_base_image}
    docker tag ${var.ecr_config.ecr_base_image} ${aws_ecr_repository.lambda-registrator.repository_url}:${var.ecr_config.ecr_image_tag}
    docker push ${aws_ecr_repository.lambda-registrator.repository_url}:${var.ecr_config.ecr_image_tag}
    EOF
  }

  depends_on = [
    aws_ecr_repository.lambda-registrator
  ]
}

resource "aws_ssm_parameter" "ca_cert" {
  name  = "/${var.lambda_name}/ca-cert"
  type  = "SecureString"
  value = var.eks_config.consul_ca_certificate_b64#var.lambda_config.consul_ca_cert
  tier = "Advanced"
}


module "lambda-registration" {
  source                    = "hashicorp/consul-lambda-registrator/aws//modules/lambda-registrator"
  version                   = "0.1.0-alpha2"
  name                      = var.ecr_config.ecr_repository_name
  consul_http_addr          = var.eks_config.hcp_consul_endpoint#var.lambda_config.kubernetes_control_plane
  consul_ca_cert_path       = aws_ssm_parameter.ca_cert.name
  ecr_image_uri             = "${aws_ecr_repository.lambda-registrator.repository_url}:${var.ecr_config.ecr_image_tag}"
  subnet_ids                = var.eks_config.private_subnets
  security_group_ids        = var.eks_config.security_group_ids
  sync_frequency_in_minutes = 2

}

variable "lambda_name" {
  default = "lambdareg"
}

#variable "region" {}

#variable "consul_ca_cert" {}

#variable "kubernetes_control_plane" {}

#variable "private_subnets" {}

#variable "security_groups" {
#  type = list(string)
#}

#variable "aws_account_id" {}

#variable "lambda_config" {
#  type = object({
#    aws_account_id           = string
#    consul_ca_cert           = string
#    kubernetes_control_plane = string
#    private_subnets          = list(string)
#    region                   = string
#    security_groups          = list(string)
#    identifier               = string
#  })
#}

variable "ecr_config" {
  type = object({
    public_ecr_region   = string
    ecr_base_image      = string
    ecr_repository_name = string
    ecr_image_tag       = string
  })

  default = {
    public_ecr_region   = "us-east-1"
    ecr_base_image      = "public.ecr.aws/hashicorp/consul-lambda-registrator:0.1.0-alpha2"
    ecr_repository_name = "lambda_registrator"
    ecr_image_tag       = "0.1.0-alpha2"
  }
}

locals {
  lambda_payments_path = "/Users/webdog/github/lambda-payments/lambda-payments.zip"
}

resource "aws_lambda_function" "lambda-payments" {
  filename         = local.lambda_payments_path
  source_code_hash = filebase64sha256(local.lambda_payments_path)
  function_name    = "payments-lambda2"
  role             = aws_iam_role.lambda_payments.arn
  handler          = "lambda-payments"
  runtime          = "go1.x"
  tags = {
    "serverless.consul.hashicorp.com/v1alpha1/lambda/enabled" = "true"
    "serverless.consul.hashicorp.com/alpha/lambda/payload-passthrough" = "true"
    "serverless.consul.hashicorp.com/alpha/lambda/invocation-mode" = "ASYNCHRONOUS"
  }
}


resource "aws_iam_policy" "lambda_payments" {
  name        = "lambda-payments-policy"
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
  name = "lambda-payments-role"

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

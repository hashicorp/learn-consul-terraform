# Create shared VPC between AWS and HCP
module "vpc" {
  source  = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  version = "2.78.0"

  name                 = local.unique_vpc
  azs                  = local.vpc_azs
  cidr                 = var.cluster_networking.vpc.cidr_block
  private_subnets      = var.cluster_networking.vpc.private_subnets
  public_subnets       = var.cluster_networking.vpc.public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}

module "tutorial_infrastructure" {
  source               = "./modules/deploy-kubernetes"
  tutorial_config      = local.tutorial_config
  lambda_payments_path = "${path.module}/lambda-payments.zip"
}

# Step 2: Register Lambda functions inside the Consul cluster

locals {
  public_ecr_region   = "us-east-1"
  ecr_base_image      = "public.ecr.aws/hashicorp/consul-lambda-registrator:0.1.0-alpha2"
  ecr_repository_name = "lambda_registrator-1"
  ecr_image_tag       = "0.1.0-alpha2"
}

# Create ECR Repository in account
resource "aws_ecr_repository" "lambda-registrator" {
  name = local.ecr_repository_name
}

# Push to ECR
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

resource "aws_ssm_parameter" "ca_cert" {
  name  = "/${local.ecr_repository_name}/ca-cert"
  type  = "SecureString"
  value = module.tutorial_infrastructure.consul_values.cert
  tier  = "Advanced"
}

resource "aws_ssm_parameter" "token" {
  name  = "/${local.ecr_repository_name}/token"
  type  = "SecureString"
  value = module.tutorial_infrastructure.consul_values.root_token
  tier  = "Advanced"
}

module "lambda-registration" {
  source                    = "hashicorp/consul-lambda-registrator/aws//modules/lambda-registrator"
  version                   = "0.1.0-beta1"
  name                      = aws_ecr_repository.lambda-registrator.name
  ecr_image_uri             = "${aws_ecr_repository.lambda-registrator.repository_url}:${local.ecr_image_tag}"
  subnet_ids                = module.vpc.private_subnets
  security_group_ids        = [module.vpc.default_security_group_id]
  sync_frequency_in_minutes = 1

  consul_http_addr       = module.tutorial_infrastructure.consul_values.endpoint
  consul_http_token_path = aws_ssm_parameter.token.name
  # consul_ca_cert_path    = aws_ssm_parameter.ca_cert.name

  depends_on = [
    null_resource.push-lambda-registrator-to-ecr
  ]
}

# # Step 3: Deploy a Lambda function for Hashicups payments

locals {
  lambda_payments_path = "./lambda-payments.zip"
}

resource "aws_lambda_function" "lambda-payments" {
  filename         = local.lambda_payments_path
  source_code_hash = filebase64sha256(local.lambda_payments_path)
  function_name    = "payments-lambda"
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
  name        = "lambda-payments-policy-1"
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
  name = "lambda-payments-role-1"

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







# # TODO: Remove from final commit.
# # TODO: This commented out code will be available in the tutorial
# #locals {
# #  lambda_payments_path = "./lambda-payments.zip"
# #  function_name = "payments"
# #  handler = "lambda-payments"
# #  runtime = "go1.x"
# #}
# #
# #data "archive_file" "lambda_payments" {
# #  type = "zip"
# # source_content = "${path.root}/payments-function"
# #  output_path = local.lambda_payments_path
# #}
# #
# #resource "aws_lambda_function" "lambda-payments" {
# #  filename         = local.lambda_payments_path
# #  source_code_hash = filebase64sha256(local.lambda_payments_path)
# #  function_name    = local.function_name
# #  role             = aws_iam_role.lambda_payments.arn
# #  handler          = local.handler
# #  runtime          = local.runtime
# #}
# #
# #resource "aws_iam_policy" "lambda_payments" {
# #  name        = "lambda-payments-policy"
# #  path        = "/"
# #  description = "IAM policy lambda payments"
# #
# #  policy = <<EOF
# #{
# #  "Version": "2012-10-17",
# #  "Statement": [
# #    {
# #      "Action": [
# #        "logs:CreateLogGroup",
# #        "logs:CreateLogStream",
# #        "logs:PutLogEvents"
# #      ],
# #      "Resource": "arn:aws:logs:*:*:*",
# #      "Effect": "Allow"
# #    }
# #  ]
# #}
# #EOF
# #}
# #
# #resource "aws_iam_role" "lambda_payments" {
# #  name = "lambda-payments-role"
# #
# #  assume_role_policy = <<EOF
# #{
# #  "Version": "2012-10-17",
# #  "Statement": [
# #    {
# #      "Action": "sts:AssumeRole",
# #      "Principal": {
# #        "Service": "lambda.amazonaws.com"
# #      },
# #      "Effect": "Allow",
# #      "Sid": ""
# #    }
# #  ]
# #}
# #EOF
# #}
# #
# #resource "aws_iam_role_policy_attachment" "lambda_payments" {
# #  role       = aws_iam_role.lambda_payments.name
# #  policy_arn = aws_iam_policy.lambda_payments.arn
# #}

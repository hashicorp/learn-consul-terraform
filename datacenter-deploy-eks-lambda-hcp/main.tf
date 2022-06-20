module "tutorial_infrastructure" {
  source               = "./modules/deploy-tutorial"
  tutorial_config      = local.tutorial_config
  #resource_config      = local.tutorial_config
}

#locals {
#  ssm_ca_cert = "/${var.lambda_tutorial_configuration.ecr_repository_name}/ca-cert"
#  ssm_token_path = "/${var.lambda_tutorial_configuration.ecr_repository_name}/token"
#  ssm_tier = "Advanced"
#  ssm_type = "SecureString"
#  lambda_payments_path = "./lambda-payments.zip"
#  unique_function = "payments-lambda-${lower(random_id.tutorial.b64_url)}"
#  lambda_handler = "lambda-payments"
#  runtime = "go1.x"
#  cw_group = "/aws/lambda/${aws_lambda_function.lambda-payments.function_name}"
#}
#
#variable "lambda_tutorial_configuration" {
#  default = {
#    registrator_name    = "lambda_registrator"
#    ecr_image_tag       = "0.1.0-alpha2"
#    ecr_base_image      = "public.ecr.aws/hashicorp/consul-lambda-registrator:0.1.0-alpha2"
#    ecr_repository_name = "lambdaconsultutorial"
#  }
#}
#
## Step 2: Register Lambda functions inside the Consul cluster
#resource "aws_ssm_parameter" "ca_cert" {
#  name  = local.ssm_ca_cert
#  type  = local.ssm_type
#  value = module.tutorial_infrastructure.consul_values.cert
#  tier  = local.ssm_tier
#}
#
#resource "aws_ssm_parameter" "token" {
#  name  = local.ssm_token_path
#  type  = local.ssm_type
#  value = module.tutorial_infrastructure.consul_values.root_token
#  tier  = local.ssm_tier
#}
#
#resource "aws_ecr_repository" "lambda-registrator" {
#  name = var.lambda_tutorial_configuration.ecr_repository_name
#}
#
#module "lambda-registration" {
#  source                    = "hashicorp/consul-lambda-registrator/aws//modules/lambda-registrator"
#  version                   = "0.1.0-beta1"
#  name                      = aws_ecr_repository.lambda-registrator.name
#  ecr_image_uri             = "${aws_ecr_repository.lambda-registrator.repository_url}:${var.lambda_tutorial_configuration.ecr_image_tag}"
#  subnet_ids                = module.vpc.private_subnets
#  security_group_ids        = [module.vpc.default_security_group_id]
#  sync_frequency_in_minutes = 1
#
#  consul_http_addr       = module.tutorial_infrastructure.consul_values.endpoint
#  consul_http_token_path = aws_ssm_parameter.token.name
#
#  depends_on = [
#    null_resource.push-lambda-registrator-to-ecr
#  ]
#}
#
#resource "null_resource" "push-lambda-registrator-to-ecr" {
#  triggers = {
#    ecr_base_image = var.lambda_tutorial_configuration.ecr_base_image
#  }
#
#  provisioner "local-exec" {
#    command = <<EOF
#    aws ecr get-login-password --region ${local.public_ecr_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.lambda-registrator.repository_url}
#    docker pull ${var.lambda_tutorial_configuration.ecr_base_image}
#    docker tag ${var.lambda_tutorial_configuration.ecr_base_image} ${aws_ecr_repository.lambda-registrator.repository_url}:${var.lambda_tutorial_configuration.ecr_image_tag}
#    docker push ${aws_ecr_repository.lambda-registrator.repository_url}:${var.lambda_tutorial_configuration.ecr_image_tag}
#    EOF
#  }
#
#  depends_on = [
#    aws_ecr_repository.lambda-registrator
#  ]
#}
#
## # Step 3: Deploy a Lambda function for Hashicups payments
#resource "aws_lambda_function" "lambda-payments" {
#  filename         = local.lambda_payments_path
#  source_code_hash = filebase64sha256(local.lambda_payments_path)
#  function_name    = local.unique_function
#  role             = aws_iam_role.lambda_payments.arn
#  handler          = local.lambda_handler
#  runtime          = local.runtime
#  tags = {
#    "serverless.consul.hashicorp.com/v1alpha1/lambda/enabled"          = "true"
#  }
#}
#
#resource "aws_cloudwatch_log_group" "function_log_group" {
#  name              = local.cw_group
#  retention_in_days = 7
#}
#
#resource "aws_iam_policy" "lambda_payments" {
#  name        = "${local.unique_function}-policy"
#  path        = "/"
#  description = "IAM policy lambda payments"
#
#  policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Action": [
#        "logs:CreateLogGroup",
#        "logs:CreateLogStream",
#        "logs:PutLogEvents"
#      ],
#      "Resource": "arn:aws:logs:*:*:*",
#      "Effect": "Allow"
#    }
#  ]
#}
#EOF
#}
#
#resource "aws_iam_role" "lambda_payments" {
#  name = "${local.unique_function}-role"
#
#  assume_role_policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Action": "sts:AssumeRole",
#      "Principal": {
#        "Service": "lambda.amazonaws.com"
#      },
#      "Effect": "Allow",
#      "Sid": ""
#    }
#  ]
#}
#EOF
#}
#
#resource "aws_iam_role_policy_attachment" "lambda_payments" {
#  role       = aws_iam_role.lambda_payments.name
#  policy_arn = aws_iam_policy.lambda_payments.arn
#}

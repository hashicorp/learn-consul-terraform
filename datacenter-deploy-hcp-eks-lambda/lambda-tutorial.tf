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
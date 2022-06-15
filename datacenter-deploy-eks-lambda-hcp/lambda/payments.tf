locals {
  lambda_payments_path = "./lambda-payments.zip"
  function_name        = "payments"
  handler              = "lambda-payments"
  runtime              = "go1.x"
}

data "archive_file" "lambda_payments" {
  type           = "zip"
  source_content = "${path.root}/payments-function"
  output_path    = local.lambda_payments_path

}

resource "aws_lambda_function" "lambda-payments" {
  filename         = local.lambda_payments_path
  source_code_hash = filebase64sha256(local.lambda_payments_path)
  function_name    = local.function_name
  role             = aws_iam_role.lambda_payments.arn
  handler          = local.handler
  runtime          = local.runtime
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

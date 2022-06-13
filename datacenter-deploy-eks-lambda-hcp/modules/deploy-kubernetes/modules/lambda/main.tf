# TODO This can probably be removed in favor of specifying the public ecr repo instead of
# creating a new private ECR repository.
# Create ECR Repository in account
resource "aws_ecr_repository" "lambda-registrator" {
  name = var.ecr_config.ecr_repository_name
}


resource "aws_lambda_function" "upload_lambda_registrator_to_ecr" {
  function_name = "ecrUpload"
  role          = "some_role"
  architectures = ["x86_64"]
  runtime       = "python3.9"
  handler       = "upload.main"

}


# Push to ECR
# TODO This can be moved to a Lambda function itself, to remove the null_resource invocation
resource "null_resource" "push-lambda-registrator-to-ecr" {
  triggers = {
    ecr_base_image = var.ecr_config.ecr_base_image
  }

  provisioner "local-exec" {
    command = <<EOF
    aws ecr get-login-password --region ${var.ecr_config.public_ecr_region} | docker login --username AWS --password-stdin ${var.lambda_config.aws_account_id}.dkr.ecr.${var.lambda_config.region}.amazonaws.com
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
  value = var.lambda_config.consul_ca_cert
}


module "lambda-registration" {
  source                    = "hashicorp/consul-lambda-registrator/aws//modules/lambda-registrator"
  version                   = "0.1.0-alpha2"
  name                      = var.ecr_config.ecr_repository_name
  consul_http_addr          = var.lambda_config.kubernetes_control_plane
  consul_ca_cert_path       = aws_ssm_parameter.ca_cert.name
  ecr_image_uri             = "${aws_ecr_repository.lambda-registrator.repository_url}:${var.ecr_config.ecr_image_tag}"
  subnet_ids                = var.lambda_config.private_subnets
  security_group_ids        = var.lambda_config.security_groups
  sync_frequency_in_minutes = 5

}
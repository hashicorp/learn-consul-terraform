module "lambda-registration" {
  source                    = "hashicorp/consul-lambda-registrator/aws//modules/lambda-registrator"
  version                   = "0.1.0-beta1"
  name                      = aws_ecr_repository.lambda-registrator.name
  ecr_image_uri             = "${aws_ecr_repository.lambda-registrator.repository_url}:${local.ecr_image_tag}"
  subnet_ids                = module.vpc.private_subnets
  security_group_ids        = [module.vpc.default_security_group_id]
  sync_frequency_in_minutes = 1

  consul_http_addr       = hcp_consul_cluster.main.consul_public_endpoint_url
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
  value = hcp_consul_cluster_root_token.token.secret_id
  tier  = "Advanced"
}



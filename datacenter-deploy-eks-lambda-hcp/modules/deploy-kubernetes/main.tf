module "aws-tutorial-deployment" {
  source               = "./modules/aws"
  aws_config           = local.aws_config
  lambda_payments_path = var.lambda_payments_path
}

module "hcp-tutorial-deployment" {
  source     = "./modules/hcp"
  hcp_config = local.hcp_config
}

module "aws-tutorial-deployment" {
  source               = "./modules/aws"
  aws_config           = local.aws_config
  lambda_payments_path = var.lambda_payments_path
  cluster_name         = "learn-consul-lambda"
  eks_lambda_iam_arn   = var.eks_lambda_iam_arn
}

module "hcp-tutorial-deployment" {
  source     = "./modules/hcp"
  hcp_config = local.hcp_config
}

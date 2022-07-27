locals {
  public_ecr_region    = var.vpc_region
  ecr_base_image       = "public.ecr.aws/hashicorp/consul-lambda-registrator:0.1.0-beta1"
  ecr_image_tag        = "0.1.0-beta1"
  lambda_payments_path = "../lambda-payments.zip"
  ecr_repository_name  = "lambda_registrator-${module.render_tutorial.tutorial_outputs.hcp_cluster_id}"
  lambda_payments_name = module.render_tutorial.tutorial_outputs.lambda_payments_name
}
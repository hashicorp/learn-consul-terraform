locals {
  public_ecr_region    = var.vpc_region
  ecr_base_image       = module.render_tutorial.tutorial_outputs.ecr_base_image
  ecr_image_tag        = module.render_tutorial.tutorial_outputs.ecr_image_tag
  ecr_repository_name  = module.render_tutorial.tutorial_outputs.ecr_repository_name
  lambda_payments_name = module.render_tutorial.tutorial_outputs.lambda_payments_name
  lambda_payments_path = "./lambda-payments.zip"
  lambda_products_name = module.render_tutorial.tutorial_outputs.lambda_products_name
  lambda_products_path = "./lambda-products.zip"
  consul_datacenter    = module.render_tutorial.tutorial_outputs.hcp_cluster_id
}

output "tutorial_outputs" {
  value = {
    ecr_base_image       = local.ecr_base_image
    ecr_image_tag        = local.ecr_image_tag
    ecr_repository_name  = local.ecr_repository_name
    lambda_payments_name = local.lambda_payments_name
    lambda_payments_path = local.lambda_payments_path
    lambda_products_name = local.lambda_products_name
    lambda_products_path = local.lambda_products_path
    region               = local.region
    hvn_id               = local.hvn_id
    hcp_cluster_id       = local.hcp_cluster_id
    vpc_id               = local.vpc_id
  }
}

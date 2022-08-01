output "tutorial_outputs" {
  value = {
    ecr_base_image = "public.ecr.aws/hashicorp/consul-lambda-registrator:0.1.0-beta1"
    ecr_image_tag  = "0.1.0-beta1"
    lambda_payments_path = "./lambda-payments.zip"
    ecr_repository_name  = "lambda_registrator-${local.uid}"
    lambda_payments_name = "payments-lambda-${local.uid}"
    region               = local.region
    hvn_id               = local.hvn_id
    hcp_cluster_id       = local.hcp_cluster_id
    availability_zones   = local.availability_zones
    vpc_id               = local.vpc_id
  }
}

locals {
  uid                  = random_string.cluster_id.id
  region               = var.vpc_region
  hvn_id               = "consullambda-${local.uid}"
  hcp_cluster_id       = "consullambda-${local.uid}"
  vpc_id               = "consullambda-${local.uid}"
  ecr_repository_name  = "lambdaRegistrator-${local.uid}"
  lambda_payments_name = "payments-lambda-${local.uid}"
  public_ecr_region    = local.region
  ecr_base_image       = "public.ecr.aws/hashicorp/consul-lambda-registrator:0.1.0-beta1"
  ecr_image_tag        = "0.1.0-beta1"
  lambda_payments_path = "../lambda-payments.zip"
  iam_path             = "/eks/"
  tpath                = "${path.module}/templates"
  tgw_policy           = "${local.tpath}/lambda-tgw-policy.hcl.tftpl"
  service_splitter     = "${local.tpath}/service-splitter.yaml.tftpl"
  service_intention    = "${local.tpath}/service-intentions_public-api_lambda.yaml.tftpl"
  tgw                  = "${local.tpath}/terminating-gateway-lambda-payments.yaml.tftpl"
  rdir                 = "${path.root}/practitioner"
  resources = [
    "gateways",
    "servicedefaults",
    "servicesplitters",
    "terminatinggateways",
    "serviceintentions",
    "gatewayclasses",
    "gatewayclassconfigs",
    "proxydefaults",
  ]
  kube_files = [
    "${local.rdir}/service-intentions.yaml",
    "${local.rdir}/service-splitter.yaml",
    "${local.rdir}/terminating-gateway.yaml"
  ]
}
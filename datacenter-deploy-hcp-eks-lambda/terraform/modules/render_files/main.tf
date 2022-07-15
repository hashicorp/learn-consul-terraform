locals {
  tpath = "${path.root}/script_templates"
  tgw_policy = "${local.tpath}/lambda-tgw-policy.hcl.tftpl"
  service_splitter = "${local.tpath}/service-splitter.yaml.tftpl"
  service_intention = "${local.tpath}/service_intentions_public-api_lambda.yaml.tftpl"
  tgw = "${local.tpath}/terminating-gateway-lambda-payments.yaml.tftpl"
  rdir = "${path.root}/rendered"
}

resource "local_file" "lambda-tgw-policy" {
  filename = "${local.rdir}/terminating-gateway-policy.hcl"
  content= templatefile(local.tgw_policy, {
    SERVICE_NAME = var.lambda_payments_name
  })
}

resource "local_file" "service_splitter" {
  filename = "${local.rdir}/service_splitter.yaml"
  content = templatefile(local.service_splitter, {
    SERVICE_NAME = var.lambda_payments_name
  })
}

resource "local_file" "service_intentions_public_api_lambda" {
  filename = "${local.rdir}/service_intentions.yaml"
  content = templatefile(local.service_intention, {
    LAMBDA_SERVICE = var.lambda_payments_name
    LAMBDA_UPSTREAM = "public-api"
  })
}

resource "local_file" "terminating-gateway-kubernetes" {
  filename = "${local.rdir}/terminating-gateway.yaml"
  content = templatefile(local.tgw, {
    SERVICE_NAME = var.lambda_payments_name
  })
}
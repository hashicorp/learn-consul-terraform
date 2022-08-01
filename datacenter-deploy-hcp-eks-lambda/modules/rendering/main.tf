resource "random_string" "cluster_id" {
  length  = 6
  special = false
  upper   = false
}

resource "local_file" "lambda-tgw-policy" {
  filename = "${local.rdir}/terminating-gateway-policy.hcl"
  content = templatefile(local.tgw_policy, {
    SERVICE_NAME = local.lambda_payments_name
  })
}

resource "local_file" "service_splitter" {
  filename = "${local.rdir}/service-splitter.yaml"
  content = templatefile(local.service_splitter, {
    SERVICE_NAME = local.lambda_payments_name
  })
}

resource "local_file" "service_intentions_public_api_lambda" {
  filename = "${local.rdir}/service-intentions.yaml"
  content = templatefile(local.service_intention, {
    LAMBDA_SERVICE  = local.lambda_payments_name
    LAMBDA_UPSTREAM = "public-api"
  })
}

resource "local_file" "terminating-gateway-kubernetes" {
  filename = "${local.rdir}/terminating-gateway.yaml"
  content = templatefile(local.tgw, {
    SERVICE_NAME = local.lambda_payments_name
  })
}

locals {
  # non-default context name to protect from using wrong kubeconfig
  kubeconfig_context = "_terraform-kustomization-${local.cluster_id}_"

  kubeconfig = {
    apiVersion = "v1"
    clusters = [
      {
        name = local.kubeconfig_context
        cluster = {
          certificate-authority-data = data.aws_eks_cluster.cluster.certificate_authority.0.data
          server                     = data.aws_eks_cluster.cluster.endpoint
        }
      }
    ]
    users = [
      {
        name = local.kubeconfig_context
        user = {
          token = data.aws_eks_cluster_auth.cluster.token
        }
      }
    ]
    contexts = [
      {
        name = local.kubeconfig_context
        context = {
          cluster = local.kubeconfig_context
          user    = local.kubeconfig_context
        }
      }
    ]
  }
}

locals {
  public_ecr_region    = var.vpc_region
  ecr_base_image       = "public.ecr.aws/hashicorp/consul-lambda-registrator:0.1.0-beta1"
  ecr_image_tag        = "0.1.0-beta1"
  lambda_payments_path = "../lambda-payments.zip"
  ecr_repository_name  = "lambda_registrator-${local.cluster_id}"
  lambda_payments_name = "payments-lambda-${random_string.cluster_id.id}"
  cluster_id           = "${var.cluster_id}-${random_string.cluster_id.id}"
  hvn_id               = "${var.hvn_id}-${random_string.cluster_id.id}"
  iam_path             = "/eks/"
  script_cmd           = "bash ${path.root}/script_templates/clean_kube.sh ${local.public_ecr_region} ${local.cluster_id}"
  vpc_id               = "${local.cluster_id}-vpc"
}
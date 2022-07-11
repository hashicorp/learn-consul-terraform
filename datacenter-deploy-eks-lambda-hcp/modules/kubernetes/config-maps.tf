# Dedicated config-map resource file since many of these are created and it's easier to keep them in a single context
resource "kubernetes_config_map" "hashicups_config_maps" {
  for_each = { for k, v in var.service_variables : k => v if v.has_cm == true }
  metadata {
    name = each.value.ConfigMap.cm_name
  }
  data = {
    config = each.value.ConfigMap.cm_data.config
  }
  depends_on = [kubernetes_service_account.hashicups_service_accounts]
}
resource "kubernetes_config_map" "startup_script" {
  metadata {
    name = var.startup_script_config_map_options.config_map_name
  }
  data = {
    (var.startup_script_config_map_options.config_map_file_name) = templatefile("${path.module}/${var.startup_script_config_map_options.template_file_name}", {

      kubectl_version    = var.startup_options.kubectl_version
      helm_version       = var.startup_options.helm_version
      consul_version     = var.startup_options.consul_version
      consul_k8s_version = var.startup_options.consul_k8s_version
      yq_version         = var.startup_options.yq_version
      aws_region         = var.cluster_region
      cluster_name       = var.cluster_name
      hashi_repo         = var.startup_options.hashi_repo
      hashi_yum_url      = var.startup_options.hashi_yum_url
      github_content_url = var.startup_options.github_content_url
      github_url         = var.startup_options.github_url
      kube_url           = var.startup_options.kube_url
    })
  }
}

resource "kubernetes_config_map" "startup_init_script" {
  metadata {
    name = var.startup_init_script_config_map_options.config_map_name
  }
  data = {
    (var.startup_init_script_config_map_options.config_map_file_name) = templatefile("${path.module}/${var.startup_init_script_config_map_options.template_file_name}", {

      kubectl_version    = var.startup_options.kubectl_version
      helm_version       = var.startup_options.helm_version
      consul_version     = var.startup_options.consul_version
      consul_k8s_version = var.startup_options.consul_k8s_version
      yq_version         = var.startup_options.yq_version
      aws_region         = var.cluster_region
      cluster_name       = var.cluster_name
      hashi_repo         = var.startup_options.hashi_repo
      hashi_yum_url      = var.startup_options.hashi_yum_url
      github_content_url = var.startup_options.github_content_url
      github_url         = var.startup_options.github_url
      kube_url           = var.startup_options.kube_url
    })
  }
}

resource "kubernetes_config_map" "shutdown_script" {
  metadata {
    name = var.shutdown_script_config_map_options.config_map_name
  }
  data = {
    (var.shutdown_script_config_map_options.config_map_file_name) = templatefile("${path.module}/${var.shutdown_script_config_map_options.template_file_name}", {
      aws_region   = var.cluster_region
      cluster_name = var.cluster_name
    })
  }
}
resource "kubernetes_config_map" "aws_cred_profile" {
  metadata {
    name = var.aws_creds_config_map_options.config_map_name
  }
  data = {
    (var.aws_creds_config_map_options.config_map_filename) = templatefile("${path.module}/${var.aws_creds_config_map_options.template_file_name}", {
      profile_name = var.profile_name
      role_arn     = var.role_arn
    })
  }
}
resource "kubernetes_config_map" "aws_profile_config" {
  metadata {
    name = var.aws_profile_config_map_options.config_map_name
  }
  data = {
    (var.aws_profile_config_map_options.config_map_filename) = templatefile("${path.module}/${var.aws_profile_config_map_options.template_file_name}", {
      profile_name = var.profile_name
      region       = var.cluster_region
    })
  }
}
resource "kubernetes_config_map" "hashicups_yaml_files" {
  for_each = fileset(path.module, local.directories.hashicups)
  metadata {
    name = split("/", "${path.module}/${each.value}")[5]
  }
  data = {
    config = file("../modules/kubernetes/${each.key}")
  }
}
resource "kubernetes_config_map" "calculated_consul_values" {
  metadata {
    name = "values.yaml"
  }
  data = {
    config = file("./rendered/values.yaml")
  }
}
resource "kubernetes_config_map" "hcl_policy_lambda" {
  metadata {
    name = local.cm_crd_names.lhcl #"lambda-frontend.hcl"
  }
  data = {
    config = templatefile("${path.module}/hashicups/crds/lambda/lambda-frontend.hcl.tftpl", {
      SERVICE_NAME = local.lambda_service_name
    })
  }
}
resource "kubernetes_config_map" "crd_proxydefault" {
  metadata {
    name = "proxy-defaults.yaml"
  }
  data = {
    config = file("${path.module}/hashicups/crds/proxy-defaults/proxy-global.yaml")
  }
}

resource "kubernetes_config_map" "crd_servicedefaults" {
  for_each = fileset(path.module, "hashicups/crds/service-defaults/*")
  metadata {
    name = "servicedefaults-${split("/", "${path.module}/${each.value}")[6]}"
  }
  data = {
    config = file("../modules/kubernetes/${each.key}")
  }
}
resource "kubernetes_config_map" "crd_serviceintentions" {
  for_each = fileset(path.module, "hashicups/crds/service-intentions/*")
  metadata {
    name = "serviceintentions-${split("/", "${path.module}/${each.value}")[6]}"
  }
  data = {
    config = file("../modules/kubernetes/${each.key}")
  }
}
resource "kubernetes_config_map" "crd_serviceintentions-lambda" {
  metadata {
    name = local.cm_crd_names.fesl #"serviceintentions-nginx-lambda.yaml"
  }
  data = {
    config = templatefile("${path.module}/hashicups/crds/lambda/nginx.yaml.tftpl", {
      DESTINATION_NAME = local.lambda_service_name
    })
  }
}

resource "kubernetes_config_map" "crd_terminatinggateway" {
  metadata {
    name = "terminatinggateway-frontend-lambda.yaml"
  }
  data = {
    config = templatefile("${path.cwd}/modules/kubernetes/hashicups/crds/terminating-gateway/frontend-lambda.yaml.tftpl", {
      DESTINATION_SERVICE = local.lambda_service_name
    }
    )
  }
}

resource "kubernetes_config_map" "crd_servicesplitter" {
  metadata {
    name = "servicesplitter-frontend-lambda.yaml"
  }
  data = {
    config = templatefile("${path.cwd}/modules/kubernetes/hashicups/crds/service-splitter/frontend-lambda.yaml.tftpl", {
      DESTINATION_SERVICE = local.lambda_service_name
    })
  }
}
resource "kubernetes_config_map" "crd_serviceresolver" {
  metadata {
    name = "serviceresolver-frontend-lambda.yaml"
  }
  data = {
    config = templatefile("${path.cwd}/modules/kubernetes/hashicups/crds/service-resolver/frontend-lambda.yaml.tftpl", {
      DESTINATION_SERVICE = local.lambda_service_name
    })
  }
}

resource "kubernetes_config_map" "consul-api-gateway" {
  metadata {
    name = local.cm_crd_names.capi#"consul-api-gateway.yaml"
  }
  data = {
    config = file("${path.module}/hashicups/api-gateway/consul.yaml")
  }
}
resource "kubernetes_config_map" "consul-api-gateway-routes" {

  metadata {
    name = local.cm_crd_names.cagr #"consul-api-gateway-routes.yaml"
  }
  data = {
    config = file("${path.module}/hashicups/api-gateway/routes.yaml")
  }
}

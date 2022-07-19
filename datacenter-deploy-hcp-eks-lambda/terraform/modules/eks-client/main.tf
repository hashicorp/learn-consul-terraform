resource "kubernetes_secret" "consul_secrets" {
  metadata {
    name = local.secret_name
  }
  data = {
    caCert              = var.consul_ca_file
    gossipEncryptionKey = var.gossip_encryption_key
    bootstrapToken      = var.boostrap_acl_token
  }
  type = "Opaque"
}

module "api_gateway_crd" {
  source = "../../modules/api-gw-crd"
}

resource "helm_release" "consul" {
  name       = "consul"
  repository = "https://helm.releases.hashicorp.com"
  version    = var.chart_version
  chart      = "consul"

  values = [
    templatefile("${path.root}/modules/rendering/templates/values.yaml.tftpl", {
      datacenter          = var.datacenter
      consul_hosts        = jsonencode(var.consul_hosts)
      cluster_id          = var.hcp_cluster_id
      k8s_api_endpoint    = var.k8s_api_endpoint
      consul_version      = substr(var.consul_version, 1, -1)
      api_gateway_version = var.api_gateway_version
    })
  ]
  depends_on = [module.api_gateway_crd]
}

resource "kubectl_manifest" "api_gateway_deployed" {
  yaml_body = file("${path.module}/api-gw/consul-api-gateway.yaml")
  depends_on = [module.api_gateway_crd]
}

resource "time_sleep" "wait_for_api_gw" {
  depends_on = [kubectl_manifest.api_gateway_deployed]
  create_duration = "60s"
  destroy_duration = "30s"
}

resource "kubectl_manifest" "api_gateway_route" {
  yaml_body = file("${path.module}/api-gw/routes.yaml")
  depends_on = [module.api_gateway_crd]
}

resource "kubectl_manifest" "hashicups_consul_resources" {
  for_each  = fileset(path.root, local.consul_resources_path)
  yaml_body = file(each.value)
}

resource "kubectl_manifest" "deploy_hashicups" {
  for_each = fileset(path.root, "./modules/eks-client/hashicups/app/*")
  yaml_body = file(each.value)

  provisioner "local-exec" {
    when = destroy
    interpreter = ["bash"]
    command = "./scripts/patch-resources.sh"
    on_failure = continue
  }
}


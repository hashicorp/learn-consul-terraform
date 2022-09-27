module "api_gateway_crd" {
  source = "../../modules/api-gw-crd"
}
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
      security_group      = var.security_group
    })
  ]

  depends_on = [module.api_gateway_crd, kubernetes_secret.consul_secrets]
}
# resource "kubectl_manifest" "kube_resources_service-accounts_and_config-maps" {
#   for_each   = local.service_account_config_maps
#   yaml_body  = file(each.value)
#   depends_on = [helm_release.consul]
# }

# resource "kubectl_manifest" "hashicups_resources" {
#   for_each   = fileset(path.root, local.hashicups_resources)
#   yaml_body  = file(each.value)
#   depends_on = [kubectl_manifest.kube_resources_service-accounts_and_config-maps]
# }
# resource "kubectl_manifest" "consul_service_resources" {
#   for_each   = local.consul_yamls
#   yaml_body  = file(each.value)
#   depends_on = [kubectl_manifest.hashicups_resources]
# }

# resource "kubectl_manifest" "api_gateway_deployed" {
#   yaml_body  = file("${path.module}/api-gw/consul-api-gateway.yaml")
#   depends_on = [kubectl_manifest.consul_service_resources]
# }
# resource "null_resource" "api_gateway_ready" {
#   provisioner "local-exec" {
#     command = <<EOF
# aws eks  --region ${var.region} update-kubeconfig --name ${var.eks_cluster_id}
# kubectl wait --for=condition=ready gateway/api-gateway --timeout=90s
# EOF
#   }
#   depends_on = [kubectl_manifest.api_gateway_deployed]
# }
# resource "kubectl_manifest" "api_gateway_route" {
#   yaml_body  = file("${path.module}/api-gw/routes.yaml")
#   depends_on = [null_resource.api_gateway_ready]
# }

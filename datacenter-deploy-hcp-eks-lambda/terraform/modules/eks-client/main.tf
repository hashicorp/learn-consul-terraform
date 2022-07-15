
resource "kubernetes_secret" "consul_secrets" {
  metadata {
    name = "${var.cluster_id}-hcp"
  }

  data = {
    caCert              = var.consul_ca_file
    gossipEncryptionKey = var.gossip_encryption_key
    bootstrapToken      = var.boostrap_acl_token
  }

  type = "Opaque"
}

resource "kustomization_resource" "gateway_crds" {
  for_each = var.gateway_crd.ids
  manifest = var.gateway_crd.manifests[each.value]
  depends_on = [null_resource.clean_kube]
}

resource "helm_release" "consul" {
  name       = "consul"
  repository = "https://helm.releases.hashicorp.com"
  version    = var.chart_version
  chart      = "consul"

  values = [
    templatefile("${path.module}/template/consul.tpl", {
      datacenter       = var.datacenter
      consul_hosts     = jsonencode(var.consul_hosts)
      cluster_id       = var.cluster_id
      k8s_api_endpoint = var.k8s_api_endpoint
      consul_version   = substr(var.consul_version, 1, -1)
      api_gateway_version = var.api_gateway_version
    })
  ]

  depends_on = [null_resource.clean_kube, kustomization_resource.gateway_crds, kubernetes_secret.consul_secrets]
}

resource "null_resource" "deploy_api_gateway" {
  provisioner "local-exec" {
    command = "bash ${path.module}/api-gw/deploy.sh"
    environment = {
      REGION = var.region
      CLUSTER_ID = var.cluster_id
    }
  }
  depends_on = [helm_release.consul]
}

resource "null_resource" "deploy_hashicups" {
  provisioner "local-exec" {
    command = "bash ${path.module}/deploy_hashicups.sh"
    environment = {
      REGION = var.region
      CLUSTER_ID = var.cluster_id
    }
  }
  depends_on = [null_resource.deploy_api_gateway]
}

resource "null_resource" "clean_kube" {
  triggers = {
    script_cmd   = local.script_cmd
  }
  provisioner "local-exec" {
    when = destroy
    command = self.triggers.script_cmd
  }
}
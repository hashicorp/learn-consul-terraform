locals {
  hcp_endpoint = split("https://", var.aws_config.hcp_consul_endpoint)[1]
}

resource "helm_release" "consul_enterprise" {
  chart      = "consul"
  name       = "consul"
  version    = "v0.44.0"
  repository = "https://helm.releases.hashicorp.com"

  values = [
    file("${path.module}/values.yaml")
  ]

  set {
    name  = "global.datacenter"
    value = var.aws_config.hcp_datacenter
  }

  set {
    name  = "global.image"
    value = "hashicorp/consul-enterprise:1.12.2-ent"
  }
  set {
    name  = "externalServers.hosts[0]"
    value = local.hcp_endpoint
  }
  set {
    name  = "externalServers.k8sAuthMethodHost"
    value = "${module.eks.cluster_endpoint}:443"
  }
  set {
    name  = "client.join[0]"
    value = local.hcp_endpoint
  }
  # depends_on = [kubernetes_secret.consul_gossip_key, kubernetes_secret.bootstrap_token, kubernetes_secret.consul_ca_cert, kubernetes_secret.license]
  depends_on = [module.eks, kubernetes_secret.bootstrap_token, kubernetes_secret.consul_ca_cert]
}

# resource "kubernetes_secret" "license" {
#   metadata {
#     name = "consul-ent-license"
#   }
#   type = "Opaque"
#   data = {
#     "key" = var.aws_config.consul_ent_license_b64
#   }
#   depends_on = [module.eks]
# }

resource "kubernetes_secret" "bootstrap_token" {
  metadata {
    name = "consul-bootstrap-token"
  }
  type = "Opaque"
  data = {
    "token" = var.aws_config.consul_bootstrap_token_b64
  }
  depends_on = [module.eks]
}

resource "kubernetes_secret" "consul_ca_cert" {
  metadata {
    name = "consul-ca-cert"
  }
  type = "Opaque"
  data = {
    "tls.crt" = var.aws_config.consul_ca_certificate_b64
  }
  depends_on = [module.eks]
}

resource "kubernetes_secret" "consul_gossip_key" {
  metadata {
    name = "consul-gossip-key"
  }
  type = "Opaque"
  data = {
    "key" = var.aws_config.consul_gossip_key_b64
  }
  # depends_on = [module.eks, kubernetes_secret.bootstrap_token, kubernetes_secret.consul_ca_cert, kubernetes_secret.license]
  depends_on = [module.eks, kubernetes_secret.bootstrap_token, kubernetes_secret.consul_ca_cert]
}

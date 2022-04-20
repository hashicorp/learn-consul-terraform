resource "hcp_hvn" "server" {
  hvn_id         = local.unique_hvn
  cloud_provider = var.hvn_settings.cloud_provider.aws
  region         = var.hvn_settings.region.us-east-1
  cidr_block     = var.hvn_settings.cidr_block
}
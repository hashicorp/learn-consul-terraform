output "resources" {
  sensitive = true
  value = {
    consul_root_token_accessor_id = hcp_consul_cluster.server.consul_root_token_accessor_id
    consul_ca                     = hcp_consul_cluster.server.consul_ca_file
    consul_config                 = hcp_consul_cluster.server.consul_config_file
    consul_http_addr              = hcp_consul_cluster.server.consul_public_endpoint_url
    consul_private_endpoint       = hcp_consul_cluster.server.consul_private_endpoint_url
    consul_public_endpoint        = hcp_consul_cluster.server.consul_public_endpoint_url
    consul_http_token             = hcp_consul_cluster.server.consul_root_token_secret_id
    kube_cluster_endpoint         = module.eks.cluster_endpoint
    #aws_region                    = var.resource_config.aws_region
    kube_cluster_name             = module.eks.cluster_id
    #kube_cluster_region           = var.resource_config.aws_region
    consul_gossip_key             = local.gossip_key

  }
}
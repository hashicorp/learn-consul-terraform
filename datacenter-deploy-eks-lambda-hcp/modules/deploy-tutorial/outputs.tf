output "consul_values" {
  value = {
    consul_ca_cert          = module.resources.resources.consul_ca
    gossip_key              = module.resources.resources.consul_gossip_key
    root_token              = module.resources.resources.consul_http_token
    consul_private_endpoint = module.resources.resources.consul_private_endpoint
    consul_public_endpoint  = module.resources.resources.consul_public_endpoint
    kube_cluster_endpoint   = module.resources.resources.kube_cluster_endpoint
    kube_cluster_name       = module.resources.resources.kube_cluster_name
  }
  sensitive = true
}


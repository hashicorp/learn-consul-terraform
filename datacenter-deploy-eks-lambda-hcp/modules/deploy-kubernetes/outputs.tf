output "consul_values" {
  value = {
    cert       = module.hcp-tutorial-deployment.ca_certificate_file
    gossip     = module.hcp-tutorial-deployment.consul_gossip_key
    root_token = module.hcp-tutorial-deployment.consul_bootstrap_token
    endpoint   = module.hcp-tutorial-deployment.hcp_consul_endpoint
  }
  sensitive = true
}
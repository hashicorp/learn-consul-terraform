output "outputs_sensitive" {
  value = {
    consul_bootstrap_token = local.secrets_values.bootstrap_token
  }
  sensitive = true
}

output "outputs_not_sensitive" {
  value = {
    consul_ui_address = local.consul_ui
    hashicups_url = local.hashicups_url
  }
}







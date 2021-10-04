output "client_lb_address" {
  value = "http://${aws_lb.example_client_app.dns_name}:9090/ui"
}

output "Consul_ui_address" {
  value = "http://${aws_eip.consul.public_ip}:8500"
}

output "acl_bootstrap_token" {
  value = random_uuid.bootstrap_token.result
}
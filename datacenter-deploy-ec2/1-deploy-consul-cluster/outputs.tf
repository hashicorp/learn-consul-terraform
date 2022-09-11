# output "client_lb_address" {
#   value = "http://${aws_lb.example_client_app.dns_name}:9090/ui"
# }

output "consul_ui_address" {
  value = "http://${aws_eip.consul.public_ip}:8500"
}

output "acl_bootstrap_token" {
  value = random_uuid.bootstrap_token.result
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "AWS VPC ID"
}

output "vpc_cidr_block" {
  value       = module.vpc.vpc_cidr_block
  description = "AWS VPC CIDR block"
}

output "subnet_id" {
  value       = module.vpc.public_subnets[0]
  description = "AWS public subnet"
}

output "consul_security_group" {
  value       = aws_security_group.consul.id
  description = "AWS Security group for Consul cluster"
}

output "consul_bootstrap_token_secret_arn" {
  value       = aws_secretsmanager_secret.bootstrap_token.arn
  description = "Secret ARN for Consul bootstrap token"
}

output "consul_server_ca_cert_arn" {
  value       = aws_secretsmanager_secret.ca_cert.arn
  description = "Secret ARN for Consul CA Cert"
}

output "consul_gossip_key_arn" {
  value        = aws_secretsmanager_secret.gossip_key.arn
  description = "Consul gossip key"
}

output "consul_server_http_addr" {
  value       = "http://${aws_eip.consul.public_ip}:8500"
  description = "Consul server HTTP address"
}
data "aws_secretsmanager_secret" "bootstrap_token" {
  arn = var.consul_bootstrap_token_secret_arn
}

data "aws_secretsmanager_secret_version" "bootstrap_token" {
  secret_id = data.aws_secretsmanager_secret.bootstrap_token.id
}

data "aws_secretsmanager_secret" "ca_cert" {
  arn = var.consul_server_ca_cert_arn
}

data "aws_secretsmanager_secret_version" "ca_cert" {
  secret_id = data.aws_secretsmanager_secret.ca_cert.id
}

data "aws_secretsmanager_secret" "gossip_key" {
  arn = var.consul_gossip_key_arn
}

data "aws_secretsmanager_secret_version" "gossip_key" {
  secret_id = data.aws_secretsmanager_secret.gossip_key.id
}
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "aws_secretsmanager_secret" "bootstrap_token" {
  name                    = local.bootstrap_token_name
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "bootstrap_token" {
  secret_id     = aws_secretsmanager_secret.bootstrap_token.id
  secret_string = local.secrets_values.bootstrap_token
}

resource "aws_secretsmanager_secret" "gossip_key" {
  name                    = local.gossip_key_name
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "gossip_key" {
  secret_id     = aws_secretsmanager_secret.gossip_key.id
  secret_string = local.secrets_values.gossip_key
}

resource "aws_secretsmanager_secret" "consul_ca_cert" {
  name                    = local.consul_ca_cert_name
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "consul_ca_cert" {
  secret_id     = aws_secretsmanager_secret.consul_ca_cert.id
  secret_string = local.secrets_values.consul_ca_cert
}
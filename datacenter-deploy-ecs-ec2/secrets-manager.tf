# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

##Bootstrap Token
resource "random_uuid" "bootstrap_token" {
  #count = var.acls ? 1 : 0
}

resource "aws_secretsmanager_secret" "bootstrap_token" {
  #count = var.acls ? 1 : 0
  name                    = "${var.name}-bootstrap-token"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "bootstrap_token" {
  #count         = var.acls ? 1 : 0
  secret_id     = aws_secretsmanager_secret.bootstrap_token.id
  secret_string = random_uuid.bootstrap_token.result
}

## Gossip Key
resource "random_id" "gossip_encryption_key" {
  #count       = var.secure ? 1 : 0
  byte_length = 32
}

resource "aws_secretsmanager_secret" "gossip_key" {
  #count = var.secure ? 1 : 0
  // Only 'consul_server*' secrets are allowed by the IAM role used by Circle CI
  name                    = "consul_server_${var.suffix}-gossip-encryption-key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "gossip_key" {
  #count         = var.secure ? 1 : 0
  secret_id     = aws_secretsmanager_secret.gossip_key.id
  secret_string = random_id.gossip_encryption_key.b64_std
}


## CA Certificate
resource "tls_private_key" "ca" {
  #count       = var.tls ? 1 : 0
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "ca" {
  #count           = var.tls ? 1 : 0
  key_algorithm   = "ECDSA"
  private_key_pem = tls_private_key.ca.private_key_pem

  subject {
    common_name  = "Consul Agent CA"
    organization = "HashiCorp Inc."
  }

  // 5 years.
  validity_period_hours = 43800

  is_ca_certificate  = true
  set_subject_key_id = true

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]
}

resource "aws_secretsmanager_secret" "ca_key" {
  #count = var.tls ? 1 : 0
  name = "${var.name}-ca-key"
}

resource "aws_secretsmanager_secret_version" "ca_key" {
  #count         = var.tls ? 1 : 0
  secret_id     = aws_secretsmanager_secret.ca_key.id
  secret_string = tls_private_key.ca.private_key_pem
}

resource "aws_secretsmanager_secret" "ca_cert" {
  #count = var.tls ? 1 : 0
  name = "${var.name}-ca-cert"
}

resource "aws_secretsmanager_secret_version" "ca_cert" {
  #count         = var.tls ? 1 : 0
  secret_id     = aws_secretsmanager_secret.ca_cert.id
  secret_string = tls_self_signed_cert.ca.cert_pem
}


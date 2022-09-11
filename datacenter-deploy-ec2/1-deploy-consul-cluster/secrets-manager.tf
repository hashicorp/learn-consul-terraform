## Bootstrap Token
resource "random_uuid" "bootstrap_token" {}

resource "aws_secretsmanager_secret" "bootstrap_token" {
  name                    = "${var.name}-bootstrap-token"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "bootstrap_token" {
  secret_id     = aws_secretsmanager_secret.bootstrap_token.id
  secret_string = random_uuid.bootstrap_token.result
}

## Gossip Key
resource "random_id" "gossip_encryption_key" {
  byte_length = 32
}

resource "aws_secretsmanager_secret" "gossip_key" {
  name                    = "consul_server_${var.suffix}-gossip-encryption-key"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "gossip_key" {
  secret_id     = aws_secretsmanager_secret.gossip_key.id
  secret_string = random_id.gossip_encryption_key.b64_std
}


## CA Certificate
resource "tls_private_key" "ca" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem

  subject {
    common_name  = "Consul Agent CA"
    organization = "HashiCorp Inc."
  }

  // 5 years
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
  name = "${var.name}-ca-key-1"
}

resource "aws_secretsmanager_secret_version" "ca_key" {
  secret_id     = aws_secretsmanager_secret.ca_key.id
  secret_string = tls_private_key.ca.private_key_pem
}

resource "aws_secretsmanager_secret" "ca_cert" {
  name = "${var.name}-ca-cert-1"
}

resource "aws_secretsmanager_secret_version" "ca_cert" {
  secret_id     = aws_secretsmanager_secret.ca_cert.id
  secret_string = tls_self_signed_cert.ca.cert_pem
}


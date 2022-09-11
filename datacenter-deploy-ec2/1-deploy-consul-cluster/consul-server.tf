resource "aws_instance" "consul" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  private_ip             = "10.0.4.100"
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.consul.id]
  user_data              = templatefile("./scripts/consul-server-init.sh", {
    consul_datacenter = var.consul_datacenter
    consul_acl_token  = random_uuid.bootstrap_token.result
    consul_gossip_key = random_id.gossip_encryption_key.b64_std
    consul_ca_cert    = tls_self_signed_cert.ca.cert_pem
    consul_ca_key     = tls_private_key.ca.private_key_pem
    consul_version    = var.consul_version
  })
  iam_instance_profile   = aws_iam_instance_profile.consul.name
  key_name               = var.ssh_keypair_name
  tags = {
    Name = "${var.name}-consul-server"
    Env  = "consul"
  }
}

resource "aws_eip" "consul" {
  instance = aws_instance.consul.id
  vpc      = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.consul.id
  allocation_id = aws_eip.consul.id
}
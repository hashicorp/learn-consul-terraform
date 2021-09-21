resource "aws_instance" "consul" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  private_ip             = "10.0.1.100"
  subnet_id              = module.vpc.private_subnets
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.consul.id]
  user_data              = file("./scripts/consul-server.sh")
  iam_instance_profile   = aws_iam_instance_profile.consul.name
  key_name               = aws_key_pair.pubkey.key_name
  tags = {
    Name = "${var.name}-consul-server"
    Env  = "consul"
  }
}

resource "aws_key_pair" "pubkey" {
  key_name   = "${var.name}-key"
  public_key = file(pathexpand(var.public_ssh_key))
}

output "security_group" {
  value = aws_security_group.consul.id
}

output "ec2_instance_dns" {
  value = aws_instance.consul.public_dns
}

output "ec2_instance_ip" {
  value = aws_instance.consul.public_ip
}
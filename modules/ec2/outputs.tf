output "ec2_public_ip" {
  value = aws_instance.my_servers[*].public_ip
}

output "ec2_private_ip" {
  value = aws_instance.my_servers[*].private_ip
}

output "security_groups" {
  value = aws_security_group.my_sg.id
}

output "ec2_id" {
  value = aws_instance.my_servers[*].id
}
output "bastion_host_sg_id" {
  value = aws_security_group.bastion_host_sg.id
}
output "private_hosts_sg_id" {
  value = aws_security_group.private_hosts_sg.id
}

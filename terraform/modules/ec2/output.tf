output "bastion_host_public_ip" {
  value = aws_instance.bastion_host.public_ip
}
output "bastion_host_private_ip" {
  value = aws_instance.bastion_host.private_ip
}
#output "instance_ids" {
#  value = { for k, inst in aws_instance.private_ec2 : k => inst.id }
#}
output "instances_info" {
  value = {
    for k, inst in aws_instance.private_ec2 :
    k => {
      id         = inst.id
      private_ip = inst.private_ip
    }
  }
}

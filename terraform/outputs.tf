# Output the VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.rsschool_vpc.id
}

# Output the public subnet IDs
output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = [for subnet in aws_subnet.public_subnets : subnet.id]
}

# Output the private subnet IDs
output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = [for subnet in aws_subnet.private_subnets : subnet.id]
}

# Output the Bastion Host public IP
output "bastion_public_ip" {
  description = "The public IP address of the Bastion Host"
  value       = aws_instance.bastion_host_rs_school.public_ip
}

# Output the Bastion Host privare IP
output "bastion_private_ip" {
  description = "The private IP address of the Bastion Host"
  value       = aws_instance.bastion_host_rs_school.private_ip
}
/*
# Output the Private Host IP
output "private_host_ip" {
  description = "The private IP address of the Bastion Host"
  value       = aws_instance.private_host_rs_school.private_ip
}
*/
#Output ubuntu AMI
output "ununtu_AMI" {
  value = data.aws_ami.ubuntu.image_id
}
/*
# Output the NAT Gateway ID
output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.rs_school_nat_gw.id
}
*/

# Output the Internet Gateway ID
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.igw_rs_school.id
}

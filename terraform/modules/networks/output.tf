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

# Output the private route table ID
output "private_route_table_id" {
  value = aws_route_table.private_route_table.id
}

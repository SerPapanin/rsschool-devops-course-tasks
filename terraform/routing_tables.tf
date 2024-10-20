# Public Route Table (Internet access)
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.rsschool_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_rs_school.id
  }

  tags = {
    Name = "Public Route Table rs-school"
  }
}

# Private Route Table (Internet access via NAT Gateway)
/*
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.rsschool_vpc.id

  route {
    #cidr_block = "0.0.0.0/0"
    #nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "Private Route Table rs-schooll"
  }
}
*/

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.rsschool_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    # Bastion host the network interface ID
    network_interface_id = aws_instance.bastion_host_rs_school.primary_network_interface_id
  }

  tags = {
    Name = "Private Route Table"
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_subnet_associations" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private_subnet_associations" {
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table.id
}

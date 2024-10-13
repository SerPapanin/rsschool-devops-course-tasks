# Get AZs from current region
data "aws_availability_zones" "current_azs" {
  state = "available"
}

# Set AZs to all available if not set in varibles
locals {
  use_azs = length(var.azs) > 0 ? var.azs : data.aws_availability_zones.current_azs.names
}

# Public Subnets
resource "aws_subnet" "public_subnets" {
  for_each = { for idx, cidr in var.public_subnet_cidrs : idx => cidr }

  #count             = length(var.public_subnet_cidrs)
  #cidr_block        = var.public_subnet_cidrs[count.index]
  #availability_zone = element(var.azs, count.index % length(var.azs))
  vpc_id                  = aws_vpc.rsschool_vpc.id
  cidr_block              = each.value
  availability_zone       = element(local.use_azs, tonumber(each.key) % length(local.use_azs)) # Assign AZs
  map_public_ip_on_launch = true                                                               # Get public IP to bastion instance

  tags = {
    Name = "Public Subnet ${each.key + 1} rs-school"
  }
}

# Accosiate NACL with block HTTP access for specific CIDRs
resource "aws_network_acl_association" "public_subnet_nacl_association" {
  subnet_id      = aws_subnet.public_subnets[0].id
  network_acl_id = aws_network_acl.http_https_nacl.id
}

# Private Subnets
resource "aws_subnet" "private_subnets" {
  for_each = { for idx, cidr in var.private_subnet_cidrs : idx => cidr }

  vpc_id            = aws_vpc.rsschool_vpc.id
  cidr_block        = each.value
  availability_zone = element(local.use_azs, tonumber(each.key) % length(local.use_azs)) # Assign AZs

  tags = {
    Name = "Private Subnet ${each.key + 1} rs-school"
  }
}

#Internet gateway
resource "aws_internet_gateway" "igw_rs_school" {
  vpc_id = aws_vpc.rsschool_vpc.id

  tags = {
    Name = "Internet gateway rs-school"
  }
}

#VPC Endpoints for SSM access to private instances

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.rsschool_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type = "Interface"
  tags = {
    Name = "VPC enpoint rs-school"
  }
}

/*# NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "rs_school_nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id # Use first public subnet

  tags = {
    Name = "rs-school-nat-gw"
  }
}
*/

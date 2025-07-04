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

  vpc_id                  = var.vpc_id
  cidr_block              = each.value
  availability_zone       = element(local.use_azs, tonumber(each.key) % length(local.use_azs)) # Assign AZs
  map_public_ip_on_launch = true                                                               # Automatically get public IP instances

  tags = {
    Name = "Public Subnet ${each.key + 1} rs-school"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnets" {
  for_each = { for idx, cidr in var.private_subnet_cidrs : idx => cidr }

  vpc_id            = var.vpc_id
  cidr_block        = each.value
  availability_zone = element(local.use_azs, tonumber(each.key) % length(local.use_azs)) # Assign AZs

  tags = {
    Name = "Private Subnet ${each.key + 1} rs-school"
  }
}

#Internet gateway
resource "aws_internet_gateway" "igw_rs_school" {
  vpc_id = var.vpc_id

  tags = {
    Name = "Internet gateway rs-school"
  }
}

#VPC Endpoints for SSM access to private instances

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type = "Interface"
  tags = {
    Name = "VPC enpoint rs-school"
  }
}

### Routing tables ###
# Public Route Table (Internet access)
resource "aws_route_table" "public_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_rs_school.id
  }

  tags = {
    Name = "Public Route Table rs-school"
  }
}

# Private Route Table (Internet access via NAT Gateway)
resource "aws_route_table" "private_route_table" {
  vpc_id = var.vpc_id
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

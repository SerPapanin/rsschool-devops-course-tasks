# Public Subnets
resource "aws_subnet" "public_subnets" {
  for_each = { for idx, cidr in var.public_subnet_cidrs : idx => cidr }

  #count             = length(var.public_subnet_cidrs)
  #cidr_block        = var.public_subnet_cidrs[count.index]
  #availability_zone = element(var.azs, count.index % length(var.azs))
  vpc_id            = aws_vpc.rsschool_vpc.id
  cidr_block        = each.value
  availability_zone = element(var.azs, tonumber(each.key) % length(var.azs)) # Assign AZs

  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet ${each.key + 1} rs-school"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnets" {
  for_each = { for idx, cidr in var.private_subnet_cidrs : idx => cidr }

  vpc_id            = aws_vpc.rsschool_vpc.id
  cidr_block        = each.value
  availability_zone = element(var.azs, tonumber(each.key) % length(var.azs)) # Assign AZs

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

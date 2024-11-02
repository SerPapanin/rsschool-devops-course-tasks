# Define the Network ACL

resource "aws_network_acl" "http_https_nacl" {
  vpc_id = aws_vpc.rsschool_vpc.id

  tags = {
    Name = "HTTP/HTTPS NACL"
  }
}
/*
# Allow HTTP (port 80) access from anywhere
resource "aws_network_acl_rule" "allow_http_inbound" {
  network_acl_id = aws_network_acl.http_https_nacl.id
  rule_number    = 1000
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0" # Allow from all IP addresses
  from_port      = 80          # Only HTTP port 80
  to_port        = 80
  egress         = false # Inbound rule
}

# Allow HTTPS (port 443) access from anywhere
resource "aws_network_acl_rule" "allow_https_inbound" {
  network_acl_id = aws_network_acl.http_https_nacl.id
  rule_number    = 1001
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0" # Allow from all IP addresses
  from_port      = 443         # Only HTTPS port 443
  to_port        = 443
  egress         = false # Inbound rule
}
*/

# Block access on HTTP (port 80) for specific CIDRs
resource "aws_network_acl_rule" "block_http_for_cidrs" {
  count          = length(var.blocked_cidrs) # Loop over the list of blocked CIDRs
  network_acl_id = aws_network_acl.http_https_nacl.id
  rule_number    = 100 + count.index
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = var.blocked_cidrs[count.index] # CIDRs to block access from
  from_port      = 80                             # Block HTTP port 80
  to_port        = 80
  egress         = false # Inbound rule
}

# Block access on HTTPS (port 443) for specific CIDRs
resource "aws_network_acl_rule" "block_https_for_cidrs" {
  count          = length(var.blocked_cidrs) # Loop over the list of blocked CIDRs
  network_acl_id = aws_network_acl.http_https_nacl.id
  rule_number    = 200 + count.index # Next rule number for HTTPS blocking
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = var.blocked_cidrs[count.index] # CIDRs to block access from
  from_port      = 443                            # Block HTTPS port 443
  to_port        = 443
  egress         = false # Inbound rule
}
# Allow all outbound traffic
resource "aws_network_acl_rule" "allow_all_inbound" {
  network_acl_id = aws_network_acl.http_https_nacl.id
  rule_number    = 1000
  protocol       = "-1" # All protocols
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  egress         = false # Inbound rule
}

# Allow all outbound traffic
resource "aws_network_acl_rule" "allow_all_outbound" {
  network_acl_id = aws_network_acl.http_https_nacl.id
  rule_number    = 2000
  protocol       = "-1" # All protocols
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  egress         = true # Outbound rule
}

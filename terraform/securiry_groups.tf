# Bastion Host Security Group (conditionally allows SSH access)
resource "aws_security_group" "bastion_host_sg" {
  vpc_id = aws_vpc.rsschool_vpc.id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    description = "Allow SSH access from specific CIDR blocks"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_bastion_cidrs # Allow SSH from the specified CIDR blocks
  }
  # Allow all traffic from within the VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"                              # Allow all protocols
    cidr_blocks = [aws_vpc.rsschool_vpc.cidr_block] # Allow traffic from VPC CIDR
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow outbound traffic to anywhere
  }

  tags = {
    Name = "bastion-host-sg"
  }
}


resource "aws_security_group" "private_hosts_sg" {
  vpc_id = aws_vpc.rsschool_vpc.id

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_host_sg.id] # Allow SSH acces from bastion host
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.rsschool_vpc.cidr_block] # Allow ping from within the VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow outbound traffic to anywhere
  }

  tags = {
    Name = "private-hosts-sg"
  }
  depends_on = [aws_security_group.bastion_host_sg] # Ensure Bastion SG is created first

}

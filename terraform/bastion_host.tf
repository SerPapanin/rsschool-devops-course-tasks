data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "panin_pub_key" {
  key_name   = "panin-pub-key"
  public_key = var.panin_key

  tags = {
    Name = "Sergey Panin Generated Key"
  }
}


# Create the Bastion Host and fetch private IP

resource "aws_instance" "bastion_host_rs_school" {
  ami                         = data.aws_ami.ubuntu.image_id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnets[0].id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.panin_pub_key.key_name
  source_dest_check           = false # Disable the destination check
  # EBS volume configuration for the root volume
  root_block_device {
    volume_type = "gp3" # Specifies that this is a gp3 volume
    volume_size = 8     # Volume size in GB
    iops        = 3000  # gp3 allows custom IOPS, with a minimum of 3,000
    throughput  = 125   # You can specify throughput in MiB/s, minimum is 125 for gp3
  }

  iam_instance_profile = aws_iam_instance_profile.bastion_ssm_profile_rs_school.name

  security_groups = [aws_security_group.bastion_host_sg.id]

  tags = {
    Name = "Bastion Host rs-school"
  }

  user_data = <<-EOF
    #!/bin/bash
    hostname bastion_host
    apt-get update
    apt-get install -y iptables

    # Install and start the SSM agent
    snap install amazon-ssm-agent --classic
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent

    # Enable IP forwarding for routing
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    sysctl -p /etc/sysctl.conf

    # Set up NAT to allow private instances to access the internet through Bastion
    iptables -t nat -A POSTROUTING -o ens5 -s 0.0.0.0/0 -j MASQUERADE
  EOF
}

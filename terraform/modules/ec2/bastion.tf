# Create the SSH key pair for the bastion host
resource "aws_key_pair" "host_pub_key" {
  key_name   = "host-pub-key"
  public_key = var.public_ssh_key

  tags = {
    Name = "Public SSH key Generated Key"
  }
}


# Create the Bastion Host in the first public subnet and fetch private IP
resource "aws_instance" "bastion_host" {
  ami                         = data.aws_ami.ubuntu.image_id
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet_ids[0]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.host_pub_key.key_name
  source_dest_check           = false # Disable the destination check
  # EBS volume configuration for the root volume
  root_block_device {
    volume_type = "gp3" # Specifies that this is a gp3 volume
    volume_size = 8     # Volume size in GB
    iops        = 3000  # gp3 allows custom IOPS, with a minimum of 3,000
    throughput  = 125   # You can specify throughput in MiB/s, minimum is 125 for gp3
  }

  iam_instance_profile = var.bastion_ssm_profile_name

  vpc_security_group_ids = [
    var.private_hosts_sg_id,
  ]
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

    # Install NGINX and start
    apt-get -y install nginx
    systemctl enable nginx
    systemctl start nginx

    # Enable IP forwarding for routing
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    sysctl -p /etc/sysctl.conf

    # Set up NAT to allow private instances to access the internet through Bastion
    iptables -t nat -A POSTROUTING -o ens5 -s 0.0.0.0/0 -j MASQUERADE
  EOF
}
# Add default route via bastion for
resource "aws_route" "default_via_bastion" {
  route_table_id         = var.private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.bastion_host.primary_network_interface_id

  lifecycle {
    create_before_destroy = true
  }
}

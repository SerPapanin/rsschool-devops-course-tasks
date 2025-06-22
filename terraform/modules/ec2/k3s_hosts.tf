#Generate random string for k3s token
resource "random_string" "k3s_token" {
  length  = 30    # Length of the random string
  special = false # Include special characters
  upper   = true  # Include uppercase letters
  lower   = true  # Include lowercase letters
}

# Create the EC2 control plane in private subnet
resource "aws_instance" "k3s_control_plane" {
  ami           = data.aws_ami.ubuntu.image_id
  instance_type = "t3a.medium"
  subnet_id     = var.private_subnet_ids[0]
  key_name      = aws_key_pair.host_pub_key.key_name
  root_block_device {
    volume_type = "gp3" # Specifies that this is a gp3 volume
    volume_size = 8     # Volume size in GB
    iops        = 3000  # gp3 allows custom IOPS, with a minimum of 3,000
    throughput  = 125   # You can specify throughput in MiB/s, minimum is 125 for gp3
  }
  iam_instance_profile = var.private_ssm_profile_name

  vpc_security_group_ids = [
    var.private_hosts_sg_id
  ]
  tags = {
    Name = "K3S-control_plane"
  }

  user_data  = <<-EOF
    #!/bin/bash
    hostname bastion_host
    apt-get update

    # Install and start the SSM agent
    snap install amazon-ssm-agent --classic
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
    # Installing k3s control plane
    curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode "644" --token ${random_string.k3s_token.result} --kube-apiserver-arg "bind-address=0.0.0.0"
    curl -s http://169.254.169.254/latest/meta-data/local-ipv4 > /var/lib/rancher/k3s/server/ip
  EOF
  depends_on = [aws_instance.bastion_host]
}

# Create the EC2 and install worker node in privte subnet

resource "aws_instance" "k3s_worker_node01" {
  ami           = data.aws_ami.ubuntu.image_id
  instance_type = "t3.micro"
  subnet_id     = var.private_subnet_ids[1]
  key_name      = aws_key_pair.host_pub_key.key_name
  root_block_device {
    volume_type = "gp3" # Specifies that this is a gp3 volume
    volume_size = 8     # Volume size in GB
    iops        = 3000  # gp3 allows custom IOPS, with a minimum of 3,000
    throughput  = 125   # You can specify throughput in MiB/s, minimum is 125 for gp3
  }
  iam_instance_profile = var.private_ssm_profile_name

  vpc_security_group_ids = [var.private_hosts_sg_id]

  tags = {
    Name = "K3S-worker_node01"
  }

  user_data  = <<-EOF
    #!/bin/bash
    hostname bastion_host
    apt-get update

    # Install and start the SSM agent
    snap install amazon-ssm-agent --classic
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
    curl -sfL https://get.k3s.io | K3S_URL=https://${aws_instance.k3s_control_plane.private_ip}:6443 K3S_TOKEN=${random_string.k3s_token.result} sh -
  EOF
  depends_on = [aws_instance.bastion_host]
}

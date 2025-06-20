# Create the Host01 in privte subnet

resource "aws_instance" "private_ec2" {
  #for_each      = toset(var.private_subnet_ids)
  count         = length(var.private_subnet_ids)
  ami           = data.aws_ami.ubuntu.image_id
  instance_type = "t3.micro"
  subnet_id     = var.private_subnet_ids[count.index]
  key_name      = aws_key_pair.host_pub_key.key_name
  root_block_device {
    volume_type = "gp3" # Specifies that this is a gp3 volume
    volume_size = 8     # Volume size in GB
    iops        = 3000  # gp3 allows custom IOPS, with a minimum of 3,000
    throughput  = 125   # You can specify throughput in MiB/s, minimum is 125 for gp3
  }
  iam_instance_profile = var.private_ssm_profile_name

  vpc_security_group_ids = [
    var.private_hosts_sg_id,
  ]

  tags = {
    Name = "private-rs-school-ec2-${count.index + 1}"
  }

  user_data  = <<-EOF
    #!/bin/bash
    apt-get update

    # Install and start the SSM agent
    snap install amazon-ssm-agent --classic
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent

  EOF
  depends_on = [aws_instance.bastion_host]
}

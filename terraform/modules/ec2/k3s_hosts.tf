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
    Role = "k3s-master"
  }

  user_data  = <<-EOF
    #!/bin/bash
    hostname k3s-control-plane
    apt-get update && apt install -y jq awscli

    #Set default region to AWS cli
    mkdir -p ~/.aws
    echo "[default]" > ~/.aws/config
    echo "region = ${var.aws_region}" >> ~/.aws/config

    # Install and start the SSM agent
    snap install amazon-ssm-agent --classic
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent

    # Installing k3s control plane
    curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode "644" --token ${random_string.k3s_token.result} --kube-apiserver-arg "bind-address=0.0.0.0"
    curl -s http://169.254.169.254/latest/meta-data/local-ipv4 > /var/lib/rancher/k3s/server/ip

    #Install HELM
    snap install helm --classic
  EOF
  depends_on = [aws_instance.bastion_host]
}
# Send K3S configuration to SSM Document
resource "aws_ssm_document" "upload_k3s_config" {
  name          = "K3s_server_Config"
  document_type = "Command"
  content = jsonencode({
    schemaVersion = "2.2",
    description   = "Upload k3s.yaml to SSM Parameter Store",
    mainSteps = [
      {
        action = "aws:runShellScript"
        name   = "K3s_server_Config"
        inputs = {
          runCommand = [
            # Wait for kubeconfig to be available
            "while [ ! -f /etc/rancher/k3s/k3s.yaml ]; do sleep 2; done",
            # Upload to Parameter Store
            "aws ssm put-parameter --name /k3s/kubeconfig --type SecureString --overwrite --value \"$(cat /etc/rancher/k3s/k3s.yaml)\" --region $(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)"
          ]
        }
      }
    ]
  })
}

# Wait until instance health check is passed
resource "null_resource" "wait_for_health_check_k3s_master" {
  depends_on = [aws_instance.k3s_control_plane]

  provisioner "local-exec" {
    command = <<-EOT
      INSTANCE_ID="${aws_instance.k3s_control_plane.id}"
      STATUS=$(aws ec2 describe-instance-status --instance-ids $INSTANCE_ID --query "InstanceStatuses[0].InstanceStatus.Status" --output text)

      while [ "$STATUS" != "ok" ]; do
        echo "Waiting for instance health check to pass..."
        sleep 10
        STATUS=$(aws ec2 describe-instance-status --instance-ids $INSTANCE_ID --query "InstanceStatuses[0].InstanceStatus.Status" --output text)
      done
      echo "Instance health check passed!"
    EOT
  }
}
resource "aws_ssm_association" "run_on_k3s_master" {
  name = aws_ssm_document.upload_k3s_config.name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.k3s_control_plane.id]
  }
  depends_on = [null_resource.wait_for_health_check_k3s_master]
}

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
    var.bastion_host_sg_id
  ]
  tags = {
    Name = "Bastion Host rs-school"
  }

  user_data = <<-EOF
    #!/bin/bash
    hostname bastion_host
    apt-get update
    apt-get install -y iptables jq awscli

    #Set default region to AWS cli
    mkdir -p ~/.aws
    echo "[default]" > ~/.aws/config
    echo "region = ${var.aws_region}" >> ~/.aws/config

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

# Wait until instance health check is passed
resource "null_resource" "wait_for_health_check_bastion" {
  depends_on = [aws_instance.bastion_host]

  provisioner "local-exec" {
    command = <<-EOT
      INSTANCE_ID="${aws_instance.bastion_host.id}"
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

#Prepare config files for NGINX reverse proxy
data "template_file" "nginx_k3s_conf" {
  template = file("./templates/nginx_k3s.tpl")
  vars = {
    k3s_private_ip = "${aws_instance.k3s_control_plane.private_ip}"
  }
}
data "template_file" "nginx_jenkins_conf" {
  template = file("./templates/nginx_jenkins.tpl")
  vars = {
    k3s_private_ip = "${aws_instance.k3s_control_plane.private_ip}"
  }
}

# Store the nginx configuration in SSM parameters
resource "aws_ssm_parameter" "nginx_k3s_conf" {
  name  = "/conf/nginx_k3s_conf"
  type  = "String"
  value = data.template_file.nginx_k3s_conf.rendered
}
resource "aws_ssm_parameter" "nginx_jenkins_conf" {
  name  = "/conf/nginx_jenkins_conf"
  type  = "String"
  value = data.template_file.nginx_jenkins_conf.rendered
}

# SSM document to apply config, copy extra files, restart service, and run a final command
resource "aws_ssm_document" "apply_nginx_conf" {
  name          = "apply_nginx_conf_ssm"
  document_type = "Command"
  content = jsonencode({
    schemaVersion = "2.2",
    description   = "Apply nginx reverse proxy k3s config, copy extra files, restart service, and run post-restart command",
    mainSteps = [
      {
        action = "aws:runShellScript",
        name   = "applyConfigAndCopyFiles",
        inputs = {
          runCommand = [
            # Retrieve the configuration file and additional files from SSM Parameter Store
            "aws ssm get-parameter --name '/conf/nginx_k3s_conf' --query 'Parameter.Value' --output text > /etc/nginx/modules-enabled/k3s.conf",
            "aws ssm get-parameter --name '/conf/nginx_jenkins_conf' --query 'Parameter.Value' --output text > /etc/nginx/sites-enabled/jenkins.conf",
            # Restart the service after applying all configuration and files
            "systemctl restart nginx"
          ]
        }
      }
    ]
  })
}

# Associate the SSM document with bastion host
resource "aws_ssm_association" "apply_nginx_conf_association" {
  name = aws_ssm_document.apply_nginx_conf.name
  targets {
    key    = "InstanceIds"
    values = [aws_instance.bastion_host.id]
  }
  depends_on = [null_resource.wait_for_health_check_bastion]
}

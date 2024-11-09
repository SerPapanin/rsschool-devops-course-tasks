#Prepare nginx reverse proxy config for jenkins and send it to parameter store
data "template_file" "nginx_jenkins_conf" {
  template = file("./templates/nginx_jenkins.tpl")
  vars = {
    k3s_private_ip = "${aws_instance.k3s_control_plane_rs_school.private_ip}"
  }
}

resource "aws_ssm_parameter" "nginx_jenkins_conf" {
  name  = "/conf/nginx_jenkins_conf"
  type  = "String"
  value = data.template_file.nginx_jenkins_conf.rendered
}

# SSM document to apply config, copy extra files, restart service, and run a final command
resource "aws_ssm_document" "apply_nginx_jenkins_conf" {
  name          = "apply_nginx_jenkins_conf_ssm"
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
            "CONFIG_JENKINS=$(aws ssm get-parameter --name '/conf/nginx_jenkins_conf' --query 'Parameter.Value' --output text)",

            # Write the configuration and additional files to their destinations on the instance
            "echo \"$CONFIG_JENKINS\" > /etc/nginx/sites-enabled/jenkins.conf",
            # Restart nginx service after applying all configuration and files
            "systemctl restart nginx"
          ]
        }
      }
    ]
  })
}

# Associate the SSM document with bastion host
resource "aws_ssm_association" "apply_nginx_jenkins_conf_association" {
  name = aws_ssm_document.apply_nginx_jenkins_conf.name
  targets {
    key    = "InstanceIds"
    values = [aws_instance.bastion_host_rs_school.id]
  }
  depends_on = [null_resource.wait_for_health_check_bastion]
}


######## Deploy Jenkins using HELM chart to k3s cluster
# Wait until instance health check is passed
resource "null_resource" "wait_for_health_check_master_node" {
  depends_on = [aws_instance.k3s_control_plane_rs_school]

  provisioner "local-exec" {
    command = <<-EOT
      INSTANCE_ID="${aws_instance.k3s_control_plane_rs_school.id}"
      STATUS=$(aws ec2 describe-instance-status --instance-ids $INSTANCE_ID --query "InstanceStatuses[0].InstanceStatus.Status" --output text)

      while [ "$STATUS" != "ok" ]; do
        echo "Waiting for master-node health check to pass..."
        sleep 10
        STATUS=$(aws ec2 describe-instance-status --instance-ids $INSTANCE_ID --query "InstanceStatuses[0].InstanceStatus.Status" --output text)
      done
      echo "Master-node health check passed!"
    EOT
  }
}

# Null resource to run the SSM send-command
resource "null_resource" "ssm_command_master_node" {
  # Only run this command after the EC2 instance is created
  depends_on = [null_resource.wait_for_health_check_master_node]

  provisioner "local-exec" {
    command = <<-EOT
      aws ssm send-command \
          --instance-ids ${aws_instance.k3s_control_plane_rs_school.id} \
          --document-name "AWS-RunShellScript" \
          --parameters commands=["curl -o /tmp/deploy_jenkins.sh https://raw.githubusercontent.com/SerPapanin/rsschool-devops-course-tasks/refs/heads/task_4/terraform/jenkins/deploy_jenkins.sh","chmod +x /tmp/deploy_jenkins.sh","/tmp/deploy_jenkins.sh"] \
          --comment "Deploy Jenkins via TF" \
          --region ${var.aws_region}
      EOT
  }
}

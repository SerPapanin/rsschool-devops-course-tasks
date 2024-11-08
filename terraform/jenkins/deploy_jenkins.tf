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

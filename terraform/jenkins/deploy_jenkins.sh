# Jenkins instalation script
sudo yum install git -y
echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> ~/.bashrc
source ~/.bashrc

# Download deployment files
wget -P /opt/jenkins/conf https://raw.githubusercontent.com/SerPapanin/rsschool-devops-course-tasks/refs/heads/task_4/terraform/jenkins/ingress_jenkins.yaml
wget -P /opt/jenkins/conf https://raw.githubusercontent.com/SerPapanin/rsschool-devops-course-tasks/refs/heads/task_4/terraform/jenkins/ebs_storageclass.yaml
wget -P /opt/jenkins/conf https://raw.githubusercontent.com/SerPapanin/rsschool-devops-course-tasks/refs/heads/task_4/terraform/jenkins/pvc.yaml
wget -P /opt/jenkins/conf https://raw.githubusercontent.com/SerPapanin/rsschool-devops-course-tasks/refs/heads/task_4/terraform/jenkins/jenkins_values.yaml
wget -P /opt/jenkins/conf


# Create the Jenkins namespace and apply configurations
cd /opt/jenkins/conf
kubectl create namespace jenkins
kubectl apply -f pvc.yaml -n jenkins
kubectl apply -f ingress_jenkins.yaml -n jenkins

# Install Jenkins
helm install jenkins -n jenkins -f jenkins_values.yaml jenkinsci/jenkins
sleep 30
sudo chown -R 1000:1000 /data/jenkins-data

# Jenkins instalation script
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
helm repo add jenkins https://charts.jenkins.io
helm repo update

# Download deployment files
wget -P /opt/jenkins/conf https://raw.githubusercontent.com/SerPapanin/rsschool-devops-course-tasks/refs/heads/task_4/terraform/jenkins/ingress_jenkins.yaml
wget -P /opt/jenkins/conf https://raw.githubusercontent.com/SerPapanin/rsschool-devops-course-tasks/refs/heads/task_4/terraform/jenkins/ebs_storageclass.yaml
wget -P /opt/jenkins/conf https://raw.githubusercontent.com/SerPapanin/rsschool-devops-course-tasks/refs/heads/task_4/terraform/jenkins/pvc.yaml
wget -P /opt/jenkins/conf https://raw.githubusercontent.com/SerPapanin/rsschool-devops-course-tasks/refs/heads/task_4/terraform/jenkins/jenkins_values.yaml

# Create the Jenkins namespace and apply configurations
cd /opt/jenkins/conf
kubectl create namespace jenkins
kubectl apply -f pvc.yaml -n jenkins

# Install Jenkins
helm install jenkins jenkins/jenkins -n jenkins -f jenkins_values.yaml
#Create ingress Traefik controller rule
kubectl apply -f ingress_jenkins.yaml -n jenkins
#Waiting for creation
sleep 30
sudo chown -R 1000:1000 /data/jenkins-data

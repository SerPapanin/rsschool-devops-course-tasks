# Jenkins instalation script
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
helm repo add jenkins https://charts.jenkins.io
helm repo update

# Download deployment files
mv /tmp/ingress_jenkins.yaml /opt/jenkins/conf
mv /tmp/ebs_storage_class.yaml /opt/jenkins/conf
mv /tmp/pvc.yaml /opt/jenkins/conf
mv /tmp/jenkins_values.yaml /opt/jenkins/conf

# Create the Jenkins namespace and apply persistent store configurations
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

# Step 4: Deploy Jenkins using the Helm chart
helm install jenkins jenkins/jenkins \
  --namespace jenkins \
  --set persistence.existingClaim=jenkins-pvc \
  --set persistence.enabled=true \
  --set controller.service.type=LoadBalancer \
  --set controller.service.port=8080 \
  --set controller.service.loadBalancerSourceRanges[0]=0.0.0.0/0  # Allows access from all IPs

  helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
  helm repo add jenkins https://charts.jenkins.io
  helm repo update
  helm install aws-ebs-csi-driver --namespace kube-system aws-ebs-csi-driver/aws-ebs-csi-driver
  kubectl apply -f jenkins_pvc.yaml
  export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
  helm install jenkins jenkins/jenkins -n jenkins -f jenkins_values.yaml
  kubectl create -f ingress_jenkins.yaml -n jenkins


  helm install jenkins jenkins/jenkins \
  --namespace jenkins \
  --set persistence.existingClaim=jenkins-pvc \
  --set persistence.enabled=true \
  --set controller.service.type=ClusterIP \
  --set controller.service.port=8080


    1  helm repo add jenkins https://charts.jenkins.io
    2  helm repo update
    3  helm install oci://ghcr.io/jenkinsci/helm-charts/jenkins
    4  helm install test oci://ghcr.io/jenkinsci/helm-charts/jenkins
    5  kubectl get nodes
    6  kubectl -version
    7  kubectl -v
    8  kubectl version
    9  export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
   10  helm install jenkins jenkins/jenkins   --namespace jenkins   --create-namespace   --version v5.7.10
   11  curl http://localhost
   12  curl http://localhost:8080
   13  kubectl --namespace jenkins port-forward svc/jenkins 8080:8080
   14  kubectl get svc -n jenkins
   15  helm uninstall jenkins -n jenkins
   16  nano jenkins-pvc.yaml
   17  kubectl create namespace jenkins
   18  kubectl apply -n jenkins -f jenkins-pvc.yaml
   19  kubectl get svc -n jenkins
   20  curl http://localhost:8080
   21  echo http://127.0.0.1:8080
   22  curl http://127.0.0.1:8080
   23  kubectl --namespace jenkins port-forward svc/jenkins 8080:8080


kind: Ingress
metadata:
  name: jenkins-ingress
  namespace: jenkins
  annotations:
    # Required for Traefik Ingress Controller
    traefik.ingress.kubernetes.io/router.entrypoints: web
spec:
  rules:
    - host: jenkins.local  # Replace with your domain or public IP
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: jenkins
                port:
                  number: 8080

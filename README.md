## Prometheus Deployment on K3s Cluster

## **Prerequisites**

-   A running K3s cluster (single-node setup).
-   **KUBECONFIG** stored in GHA Secrets
-   **BASTION_SG_ID** stored in GHA variables. Used for ingress access to kubectl api
-   **secrets.AWS_ROLE** AWS role configured to allow make changes in SG

### Deployment

Deployment was made using GHA pipeline through HELM chart.
- At first step using `aws ec2 authorize-security-group-ingress` adding GHA runner_ip to ingres SG
-   Second step using helm chart deploy Prometheus
```     helm repo add bitnami https://charts.bitnami.com/bitnami
        helm repo update
        helm upgrade --install my-prometheus bitnami/kube-prometheus \
          --namespace monitoring \
          --kubeconfig kubeconfig
```
-   Third step removing GHA runner_ip from ingress SG

### Ingress access

Ingress access configured through Nginx revese proxy on Bastion host and Traefik Ingress controller on K3S cluster.

### Verifications

Verify the Helm chart installation:

    ```bash
    kubectl get all -n monitoring
    kubectl get pods -n monitoring
    ```

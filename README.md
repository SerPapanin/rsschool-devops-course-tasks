# Task 8: Grafana Installation and Dashboard Creation
## Objective
In this task, you will install Grafana on your Kubernetes (K8s) cluster using a Helm chart and create a dashboard to visualize Prometheus metrics.

## Prerequisites
- Kubernetes cluster up and running.
- kubectl CLI installed and configured.
- Helm installed and configured.
- Prometheus installed and running in the cluster.


## Installation of Grafana
Grafana instalation made by github action workflow

Add the Bitnami Helm repository:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

Install Grafana in the namespace monitoring:

```bash
helm upgrade --install my-grafana bitnami/grafana \
  --namespace monitoring \
  --create-namespace \
  --set admin.password=${{ secrets.GRAFANA_ADMIN_PASS }} \
  --kubeconfig kubeconfig
```
Set your grafana admin password as github secrets **GRAFANA_ADMIN_PASS**.

### Verify Installation

Check the status of the Grafana pod:

```bash
kubectl get pods -n monitoring
kubectl get all -n monitoring
```

Grafana have external access throuh **Treafik ingress controller**


Access Grafana in your browser at http://grafana.local
As I don't have my own domain, I used local resolver (/etc/hosts)

## Configure Grafana

### Add Prometheus Data Source

- Log in to Grafana.
- Navigate to Configuration → Data Sources → Add data source.
- Select Prometheus and set the following:
URL: (e.g., http://prometheus.local:9090).
- Click Save & Test to verify the connection.

## Create a Dashboard

### 1: Add Visualization

1. Navigate to Dashboards → New Dashboard → Add a new panel.
2. Select Prometheus as the data source.
3. Enter the PromQL query for the desired metric. For example:

CPU Utilization:
```bash
sum(rate(node_cpu_seconds_total{mode!="idle"}[5m])) by (instance)
sum(rate(node_cpu_seconds_total[5m])) by (mode)
```

Memory Usage:
```bash
# Memory utilization %
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
# Memory usage
sum(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / (1024 * 1024 * 1024)
```

Disk Space Usage:
```bash
# Disk utilization %
(1 - (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"})) * 100
# Disk usage
(node_filesystem_size_bytes{mountpoint="/"} - node_filesystem_avail_bytes{mountpoint="/"}) / (1024 * 1024 * 1024)
```

4. Customize the panel's visualization and title.
5. Click Apply to save the panel.

## 2: Save Dashboard
1. After adding all necessary panels, click Save Dashboard.
2. Enter a name for the dashboard and save it.


# Task 7
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

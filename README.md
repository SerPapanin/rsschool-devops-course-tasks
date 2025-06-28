## Task 1 documentation

Repository contains the Terraform configuration files, GitHub Action yaml-files.


### Brief files and folder stucture overview:

- .github/workflows/:\
  Folder contains YAML files defining GitHub Actions workflows.
- screenshots/:\
  Directory contains screenshots of installed software versions and 2FA enabled on root and terraform_user accounts
- terraform/modules/iam:\
  Terraform directory in which was implemented creation IAM role for GitHub Actions and Identity Provider and Trust policies for Github Actions
- terraform/provider.tf:\
  Terraform file where AWS provider was configured and described
- terraform/aws_backend.conf:\
  File for configuration AWS provider to run locally: S3 and so on

### Terraform variables (variables.tf)
- _variable "aws_region"_ - default AWS region for resources creation\
- _variable "githubactioniam_policies"_ - list of Github Action policies for Github Action iam_role


### GitHub variables and GitHub Secrets variables

  - AWS_REGION: variable, default AWS region
  - AWS_BUCKET_NAME: variable, TF_STATE S3 bucket name
  - AWS_TF_STATE_FILE_NAME: variable, TF_STATE file name
  - AWS_ROLE: secret, GithubActionsRole name
  - TF_VERSION: variable, default TF runner version
  - TERRAFORM_DIR: variable, path to TF code dirrectory

  ### How to Use

Before using need to create terraform_user in AWS with necessary credentials and AWS accesskey for this user\
Configure AWS CLI localy to use this accesskey\
Create S3 bucket to store TF_STATE file and add this information to aws_backend.conf\
Initialize Terraform:\
  Run: terraform init -backend-config=aws_backend.conf\
Plan and Apply Changes:\
  Review changes by running: terraform plan\
  Apply changes by running: terraform apply\
Github actions:\
 Add necessary variables and secrets to Github -> Setings -> Secrets and variables -> Actions

## Task 02 documentation

Before usage need set values of variables in file **ts_school.auto.tfvars**\

Allowed CIDRs to SSH access to bastion host
- allowed_ssh_bastion_cidrs = [""] (Default: none)\
Private subnets CIDRs
- private_subnet_cidrs = ["10.1.6.0/24", "10.1.7.0/24"]\
Public subnets CIDRs
- public_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]\
Public SSH key pushed to instances
- public_ssh_key = "" (Default: none)\
Blocked CIDRs for NACL HTTP/HTTPS block
- blocked_cidrs = [""] (Default: none)

###Pipeline creates:
- VPC in specified region.
- Then get all AZs and spread newworks across AZs, or you can specify AZs where networks will be spread\
- Create security groups
- Create Internet gateway
- Create network ACL (allow all trafic and block HTTP access for specified CIDRs)
- Create SSM role
- Create bastion host in first public network with SSM role assigned and SSM agent installed and assiciate security groups
- Add routes to public network and private network. Route traffic to internet in private network through bastion host
- Create host in private network with SSM role and SSM agent instaled
- Create NACL rules to allow all traffic and block HTTP/HTTPS access for specified CIDRs

## Task 3 documentation
## K8S cluster with [k3s](https://k3s.io/)

#### In frame of the task K3s cluster instaled and configured automaticaly by terraform
K3s cluster consists of 1 master node and 1 worker node\
Connection to cluster implemented through nginx reverse proxy installed on Bastion host\
After cluster is created config file uploaded to Parameter Store\
For connection from local machine to cluster need to store kube config into ~/.kube/config file

### Istalation steps and verifications (manual adding node to k3s cluster)

1. **On control plane check status of k3s service**
    ```bash
    systemctl status k3s
    ```
2. **Get the server token:**
    ```bash
    sudo cat /var/lib/rancher/k3s/server/node-token
    ```
3. **Install worker node and join to the cluster**
    ```bash
   curl -sfL https://get.k3s.io | K3S_URL=https://<master_none_IP>:6443 K3S_TOKEN=<server_token> sh -
    ```
4. Check the nodes list from master node
 ```bash
    sudo kubectl get nodes
```
    Result:
```bash
root@ip-10-0-6-109:~# kubectl get nodes
NAME            STATUS   ROLES                  AGE   VERSION
ip-10-0-6-109   Ready    control-plane,master   45m   v1.32.5+k3s1
ip-10-0-6-149   Ready    <none>                 36m   v1.32.5+k3s1
```
5. Deploy a Simple Workload

   ```bash
   kubectl apply -f https://k8s.io/examples/pods/simple-pod.yaml
   ```
6. Verify that the pod is running:

   ```bash
   kubectl get pods
   ```
7. For connection from local machine used NGINX reverse proxy installed on bastion host

NGINX config
```
stream {
        upstream api {
                server <kube-api-server-ip>:6443;
        }
        server {
                listen 6443; # this is the port exposed by nginx on your proxy server
                proxy_pass api;
                proxy_timeout 20s;
        }
}
```
8.  kubectl config on local machine

Copied from k3s-server `/etc/rancher/k3s/k3s.yaml` to local machine `~/.kube/config`. `server` field is changed.

```yaml
apiVersion: v1
clusters:
  - cluster:
      certificate-authority-data: LRMEMMW2 # shortened for readability
      server: https://<BASTION_HOST_IP>:6443
    name: default
... # shortened for readability
```

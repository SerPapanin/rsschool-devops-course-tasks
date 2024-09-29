## Task 1 documentation

Repository contains the Terraform configuration files, GitHub Action yaml-files.

Repository folders structure:\
├── .github\
│   └── workflows\
├── readme.md\
├── screenshots\
│   ├── root_MFA.png\
│   ├── sw_versions.png\
│   └── terraform_user_MFA.png\
└── terraform\
    ├── aws_backend.conf\
    ├── iam_role.tf\
    ├── provider.tf\
    └── variables.tf\


### Brief files and folder stucture overview:

- .github/workflows/:\
  Folder contains YAML files defining GitHub Actions workflows.
- screenshots/:\
  Directory contains screenshots of installed software versions and 2FA enabled on root and terraform_user accounts
- iam_role.tf:\
  Terraform file in which was implemented creation IAM role for GitHub Actions and Identity Provider and Trust policies for Github Actions
- provider.tf:\
  Terraform file where AWS provider was configured and described
- variables.tf:\
  This file defines the input variables for the Terraform project.
- aws_backend.conf:\
  File for configuration AWS provider to run locally: S3 and so on

### Terraform variables (variables.tf)
- _variable "aws_region"_ - default AWS region for resources creation\
- _variable "githubactioniam_policies"_ - list of Github Action policies for Github Action iam_role


### GitHub variables and GitHub Secrets variables

  - AWS_REGION: variable, default AWS region
  - AWS_ACCOUNT_ID: secret with AWS account ID
  - AWS_BUCKET_NAME: variable, TF_STATE S3 bucket name
  - AWS_TF_STATE_FILE_NAME: variable, TF_STATE file name
  - TERRAFORM_GITHUB_ACTIONS_ROLE_NAME: variable, GithubActionsRole name
  - TF_VERSION: variable, default TF runner version
  - TERRAFORM_DIR: variable, path to TF code dirrectory

  ### How to Use

Before using need to create terraform_user in AWS with necessary credentials and AWS accesskey for this user\
Configure AWS CLI localy to use this accesskey\
Create S3 bucket to store TF_STATE file and add this information to aws_backend.conf\
Initialize Terraform:\
  Run: terraform init\
Plan and Apply Changes:\
  Review changes by running: terraform plan\
  Apply changes by running: terraform apply\
Github actions:\
 Add necessary variables and secrets to Github -> Setings -> Secrets and variables -> Actions

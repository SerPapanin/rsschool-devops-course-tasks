resource "aws_iam_role" "GithubActionsRole" {
  name                = "GithubActionsRole"
  managed_policy_arns = var.github_action_iam_policies_list

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::440744237104:oidc-provider/token.actions.githubusercontent.com"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          },
          "StringLike" : {
            "token.actions.githubusercontent.com:sub" : "repo:SerPapanin/rsschool-devops-course-tasks:*"
          }
        }
      }
    ]
  })

  tags = {
    Name = "iam-role-GithubActionsRole"
  }
}

#Create GitHub Actions OIDC Provider
resource "aws_iam_openid_connect_provider" "github_actions_IODC_provider" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["d89e3bd43d5d909b47a18977aa9d5ce36cee184c", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]

  tags = {
    Name = "iodc-provider-github-action"
  }
}

# Create IAM role for SSM agent
resource "aws_iam_role" "ssm_role_rs_school" {
  name = "bastion-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "SSM Role for Bastion Host"
  }
}

# Attach AmazonSSMManagedInstanceCore policy to the role
resource "aws_iam_role_policy_attachment" "ssm_role_policy_rs_school" {
  role       = aws_iam_role.ssm_role_rs_school.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create an instance profile for the Bastion Host
resource "aws_iam_instance_profile" "bastion_ssm_profile_rs_school" {
  name = "bastion-ssm-profile-rs-school"
  role = aws_iam_role.ssm_role_rs_school.name
}

# S3 bucket for testing
/*resource "aws_s3_bucket" "test-s3-bucket-panin12345" {
  bucket        = "test-s3-bucket-panin12345"
  force_destroy = true

  tags = {
    Name = "test-s3-bucket-panin12345"
  }
}*/

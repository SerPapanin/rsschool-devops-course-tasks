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
    Name = "SSM Role for hosts"
  }
}

# Attach AmazonSSMManagedInstanceCore policy to the instance role
resource "aws_iam_role_policy_attachment" "ssm_role_policy_rs_school" {
  role       = aws_iam_role.ssm_role_rs_school.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
# Attach ECR RW policy to instance role
resource "aws_iam_role_policy_attachment" "ssm_role_policy_ecr_rw_attach" {
  role       = aws_iam_role.ssm_role_rs_school.name
  policy_arn = aws_iam_policy.ecr_rw_allow.arn
}


# Create a policy that allows sending SSM commands
resource "aws_iam_policy" "ssm_send_command_policy" {
  name        = "GitHubActionsSSMPolicy"
  description = "Allows GitHub Actions to send SSM commands to EC2 instances"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          #"ssm:*",
          "ssm:SendCommand",
          "ssm:PutParameter",
          "ssm:DescribeDocument",
          "ssm:DescribeInstanceInformation",
          "ssm:CreateAssociation",
          "ssm:GetDocument",
          "ssm:DescribeDocumentPermission",
          "ssm:GetCommandInvocation"
        ],
        Resource = "*"
      }
    ]
  })
  tags = {
    Name = "github-allow-ssm-commands"
  }
}

# Attach the SSM Send Command Policy to the GitHub Actions Role
resource "aws_iam_role_policy_attachment" "github_actions_policy_attachment" {
  role       = aws_iam_role.GithubActionsRole.name
  policy_arn = aws_iam_policy.ssm_send_command_policy.arn
}

#Create a policy that allow ECR RW access
resource "aws_iam_policy" "ecr_rw_allow" {
  name        = "ECR_RW_AllowPolicy"
  description = "Allow complete ECR access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:ListImages",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],
        "Resource" : "*"
    }]
  })
}
# Attach ECR RW policy to GitHub Action role
resource "aws_iam_role_policy_attachment" "github_actions_policy_ecr_attach" {
  role       = aws_iam_role.GithubActionsRole.name
  policy_arn = aws_iam_policy.ecr_rw_allow.arn
}


# S3 bucket for testing
/*resource "aws_s3_bucket" "test-s3-bucket-panin12345" {
  bucket        = "test-s3-bucket-panin12345"
  force_destroy = true

  tags = {
    Name = "test-s3-bucket-panin12345"
  }
}*/

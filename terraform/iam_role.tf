provider "aws" {
  #region = "us-east-1"
}

resource "aws_iam_role" "GithubActionsRole" {
  name = "GithubActionsRole"
  #assume_role_policy  = data.aws_iam_policy_document.instance_assume_role_policy.json # (not shown)
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/IAMFullAccess",
    "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess"
  ]

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
            #https://github.com/SerPapanin/rsschool-devops-course-tasks/
          }
        }
      }
    ]
  })

  tags = {
    Project = "rs-school"
  }
}

# GitHub Actions OIDC Provider
resource "aws_iam_openid_connect_provider" "github_actions_IODC_provider" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["d89e3bd43d5d909b47a18977aa9d5ce36cee184c", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]

  tags = {
    Project = "rs-school"
  }
}
/*data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}*/

# List of Managed Policies
/*locals {
  managed_policies = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/IAMFullAccess",
    "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess"
  ]
}

# Attach all Managed Policies in a loop
resource "aws_iam_role_policy_attachment" "GithubActionsRole_policy_attachment" {
  for_each = toset(local.managed_policies)

  role       = aws_iam_role.GithubActionsRole1.name
  policy_arn = each.value
}
*/

/*{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::440744237104:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:SerPapanin/*"
                }
            }
        }
    ]
}*/

resource "aws_iam_role" "GithubActionsRole" {
  name = "GithubActionsRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::837781915459:oidc-provider/token.actions.githubusercontent.com"
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

# Attach policies to the GitHub Actions role
resource "aws_iam_role_policy_attachment" "GithubActionsPolicyAttachments" {
  for_each   = toset(var.github_action_iam_policies_list)
  role       = aws_iam_role.GithubActionsRole.name
  policy_arn = each.value
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

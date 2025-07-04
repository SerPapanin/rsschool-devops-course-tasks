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

# Add policy to allow putting kubeconfig to SSM parameter store
resource "aws_iam_role_policy" "put_kubeconfig_to_ssm" {
  name = "allow-put-parameter-k3s"
  role = aws_iam_role.ssm_role_rs_school.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "ssm:PutParameter",
        Resource = "arn:aws:ssm:*:*:parameter/k3s/*"
      }
    ]
  })
}

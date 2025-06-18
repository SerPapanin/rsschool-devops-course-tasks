# S3 bucket for testing
resource "aws_s3_bucket" "test-s3-bucket" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name = var.bucket_name
  }
}

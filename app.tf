data "aws_caller_identity" "current" {}

locals {
  app_jar_path = pathexpand(var.app_jar_path)
  app_jar_key  = "${var.app_name}/${var.app_name}.jar"
  app_jar_hash = filemd5(local.app_jar_path)
  app_bucket   = "${var.project_name}-artifacts-${data.aws_caller_identity.current.account_id}"
}

# 12. S3 bucket that holds the application artifact
resource "aws_s3_bucket" "artifacts" {
  bucket        = local.app_bucket
  force_destroy = true

  tags = {
    Name = "${var.project_name}-artifacts"
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket                  = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "app_jar" {
  bucket      = aws_s3_bucket.artifacts.id
  key         = local.app_jar_key
  source      = local.app_jar_path
  source_hash = local.app_jar_hash
}

# 13. S3 gateway endpoint so the private instance reaches S3 without the NAT
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = {
    Name = "${var.project_name}-s3-endpoint"
  }
}

# 14. Allow the EC2 role to read the artifact
resource "aws_iam_role_policy" "artifact_read" {
  name = "${var.project_name}-artifact-read"
  role = aws_iam_role.ec2_ssm.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject"]
      Resource = "${aws_s3_bucket.artifacts.arn}/*"
    }]
  })
}

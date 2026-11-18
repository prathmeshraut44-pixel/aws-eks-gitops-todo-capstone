# Get the AWS account ID for a unique S3 bucket name
data "aws_caller_identity" "current" {}

# S3 bucket for Terraform remote state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "todo-capstone-terraform-state-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name    = "todo-capstone-terraform-state"
    Project = "todo-capstone"
  }
}

# Enable S3 bucket versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption for stored state files
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access to the state bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for Terraform state locking
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "todo-capstone-terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name    = "todo-capstone-terraform-lock"
    Project = "todo-capstone"
  }
}

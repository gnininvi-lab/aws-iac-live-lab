variable "bucket_name" {
  type        = string
  description = "Base name for the team storage bucket"
}

variable "environment" {
  type        = string
  description = "Must be exactly: Dev, Stage, or Prod"
}

resource "aws_s3_bucket" "this" {
  bucket = "${var.bucket_name}-${lower(var.environment)}"

  tags = {
    Environment = var.environment
    ManagedBy   = "Self-Service-Pipeline"
  }
}

# Enforce server-side encryption (AWS Best Practice / SAST requirement)
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Prevent accidental public exposure (Enforced at the resource level)
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

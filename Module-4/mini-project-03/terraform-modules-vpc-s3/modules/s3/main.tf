resource "aws_s3_bucket" "log_bucket" {
  bucket = "${var.bucket_name}-logs"

  tags = {
    Name        = "${var.bucket_name}-logs"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "logging" {
  bucket = aws_s3_bucket.bucket.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_rule" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    id      = "log"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "GLACIER"
    }

    expiration {
      days                         = 90
      expired_object_delete_marker = true
    }
  }
}

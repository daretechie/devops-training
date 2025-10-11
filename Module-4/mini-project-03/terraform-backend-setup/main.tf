provider "aws" {
  region = "us-east-1"
}

# Choose a unique name for your bucket
variable "tfstate_bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  type        = string
  default     = "daretechie-devops-tf-state-bucket"
}

resource "aws_s3_bucket" "tfstate" {
  bucket = var.tfstate_bucket_name
}

resource "aws_s3_bucket_versioning" "tfstate_versioning" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "tflock" {
  name           = "terraform-lock"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
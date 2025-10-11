terraform {
  backend "s3" {
    bucket         = "daretechie-devops-tf-state-bucket" # Must match the name in the previous step
    key            = "main/terraform.tfstate" # We use a key to keep this state separate
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}


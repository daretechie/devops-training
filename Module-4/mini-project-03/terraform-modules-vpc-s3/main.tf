provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  subnet_cidr_block = var.subnet_cidr_block
  env_prefix = var.env_prefix
}

module "s3" {
  source = "./modules/s3"
  bucket_name = var.bucket_name
}
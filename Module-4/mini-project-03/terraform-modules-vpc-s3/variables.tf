variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "subnet_cidr_block" {
  description = "The CIDR block for the subnet"
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string  
}

variable "env_prefix" {
  description = "Environment prefix"
  type        = string  
}
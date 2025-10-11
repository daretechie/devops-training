Mini Project: Terraform Modules - VPC and S3 Bucket with Backend Storage
Purpose:
In this mini project, you will use Terraform to create modularized configurations for building an Amazon Virtual Private Cloud (VPC) and an Amazon S3 bucket. Additionally, you will configure Terraform to use Amazon S3 as the backend storage for storing the Terraform state file.

Objectives:
Terraform Modules:

Learn how to create and use Terraform modules for modular infrastructure provisioning.
VPC Creation:

Build a reusable Terraform module for creating a VPC with specified configurations.
S3 Bucket Creation:

Develop a Terraform module for creating an S3 bucket with customizable settings.
Backend Storage Configuration:

Configure Terraform to use Amazon S3 as the backend storage for storing the Terraform state file.
Project Tasks:
Task 1: VPC Module
Create a new directory for your Terraform project (e.g., terraform-modules-vpc-s3).

Inside the project directory, create a directory for the VPC module (e.g., modules/vpc).

Write a Terraform module (modules/vpc/main.tf) for creating a VPC with customizable configurations such as CIDR block, subnets, etc.

Create a main Terraform configuration file (main.tf) in the project directory, and use the VPC module to create a VPC.

Task 2: S3 Bucket Module
Inside the project directory, create a directory for the S3 bucket module (e.g., modules/s3).

Write a Terraform module (modules/s3/main.tf) for creating an S3 bucket with customizable configurations such as bucket name, ACL, etc.

Modify the main Terraform configuration file (main.tf) to use the S3 module and create an S3 bucket.

Task 3: Backend Storage Configuration
Configure Terraform to use Amazon S3 as the backend storage for storing the Terraform state file.

Create a backend configuration file (e.g., backend.tf) specifying the S3 bucket and key for storing the state.

Initialize the Terraform project using the command: terraform init.

Apply the Terraform configuration to create the VPC and S3 bucket using the command: terraform apply.

Instructions:
Create a new directory for your Terraform project using a terminal (mkdir terraform-modules-vpc-s3).

Change into the project directory (cd terraform-modules-vpc-s3).

Create directories for the VPC and S3 modules (mkdir -p modules/vpc and mkdir -p modules/s3).

Write the VPC module configuration (nano modules/vpc/main.tf) and the S3 module configuration (nano modules/s3/main.tf).

Create the main Terraform configuration file (nano main.tf) and use the VPC and S3 modules.

Copy
module "vpc" {"\n source = \"./modules/vpc\"\n // Add variables for customizing the VPC module if needed\n"}

module "s3_bucket" {"\n source = \"./modules/s3\"\n // Add variables for customizing the S3 bucket module if needed\n"}

provider "aws" {"\n region = \"us-east-1\" # Change this to your desired AWS region\n"}

terraform {"\n backend \"s3\" {\n bucket = \"your-terraform-state-bucket\"\n key = \"terraform.tfstate\"\n region = \"us-east-1\" # Change this to your desired AWS region\n encrypt = true\n dynamodb_table = \"your-lock-table\"\n "}
}
Create the backend configuration file (nano backend.tf) to specify the backend storage.

Copy
terraform {"\n backend \"s3\" {\n bucket = \"your-terraform-state-bucket\"\n key = \"terraform.tfstate\"\n region = \"us-east-1\" # Change this to your desired AWS region\n encrypt = true\n dynamodb_table = \"your-lock-table\"\n "}
}
Initialize the Terraform project using terraform init.

Apply the Terraform configuration using terraform apply and confirm the creation of the VPC and S3 bucket.

Document your observations and any challenges faced during the project.

Side Note:

Copy

- Ensure you have the AWS CLI installed and configured with appropriate credentials.
- Modify variables and configurations in the modules based on your specific requirements.
- Replace placeholder values in the main and backend configuration files with actual values.
- This is a learning exercise; use it to gain hands-on experience with Terraform modules and backend storage.

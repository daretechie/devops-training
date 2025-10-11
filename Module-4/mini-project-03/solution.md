# Step-by-Step Guide to Terraform Modules Project (Production Approach)

This guide provides a complete, production-oriented solution for the mini-project described in `notes.md`.

## 1. Project Structure

We will create two separate directories:

1.  `terraform-backend-setup`: To create and manage the S3 bucket and DynamoDB table for our backend.
2.  `terraform-modules-vpc-s3`: The main project that will use the backend created in the first step.

```bash
mkdir -p terraform-backend-setup
mkdir -p terraform-modules-vpc-s3/modules/{vpc,s3}

# Create files for backend setup
touch terraform-backend-setup/main.tf

# Create files for main project
cd terraform-modules-vpc-s3
touch main.tf variables.tf terraform.tfvars backend.tf
touch modules/vpc/main.tf modules/vpc/variables.tf
touch modules/s3/main.tf modules/s3/variables.tf
cd ..
```

## 2. Create the Backend Infrastructure (Production Approach)

In a production environment, all infrastructure should be managed by code. This includes the S3 bucket and DynamoDB table for the Terraform backend. We create them using a separate, minimal Terraform project.

**`terraform-backend-setup/main.tf`**

```terraform
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
```

Now, let's create these resources. This project will use a local state file, which is acceptable for a small, rarely changed project like this one.

```bash
cd terraform-backend-setup
terraform init
terraform apply --auto-approve
cd ..
```

## 3. Configure the Terraform Backend

Now that our backend infrastructure exists, we can configure our main project to use it.

**`terraform-modules-vpc-s3/backend.tf`**

```terraform
terraform {
  backend "s3" {
    bucket         = "daretechie-devops-tf-state-bucket" # Must match the name in the previous step
    key            = "main/terraform.tfstate" # We use a key to keep this state separate
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
```

## 4. Create the VPC Module

**`terraform-modules-vpc-s3/modules/vpc/variables.tf`**

```terraform
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "env_prefix" {
  description = "Environment prefix"
  type        = string
}
```

**`terraform-modules-vpc-s3/modules/vpc/main.tf`**

```terraform
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr_block
  tags = {
    Name = "${var.env_prefix}-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.env_prefix}-route-table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}
```

## 5. Create the S3 Bucket Module

**`terraform-modules-vpc-s3/modules/s3/variables.tf`**

```terraform
variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}
```

**`terraform-modules-vpc-s3/modules/s3/main.tf`**

```terraform
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  acl    = "private"

  tags = {
    Name = var.bucket_name
  }
}
```

## 6. Configure the Root Module

**`terraform-modules-vpc-s3/variables.tf`**

```terraform
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "env_prefix" {
  description = "Environment prefix"
  type        = string
}
```

**`terraform-modules-vpc-s3/terraform.tfvars`**

```
vpc_cidr_block    = "10.0.0.0/16"
subnet_cidr_block = "10.0.1.0/24"
bucket_name       = "daretechie-devops-tf-module-bucket" # Choose a unique bucket name
env_prefix        = "dev"
```

**`terraform-modules-vpc-s3/main.tf`**

```terraform
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source            = "./modules/vpc"
  vpc_cidr_block    = var.vpc_cidr_block
  subnet_cidr_block = var.subnet_cidr_block
  env_prefix        = var.env_prefix
}

module "s3_bucket" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
}
```

## 7. Execute Terraform

Now you are ready to create the main infrastructure.

```bash
cd terraform-modules-vpc-s3
```

1.  **Initialize Terraform.** This will download providers and configure the S3 backend.

    ```bash
    terraform init
    ```

2.  **Plan and Apply.**

    ```bash
    terraform plan
    terraform apply --auto-approve
    ```

## 8. Clean Up

To destroy all resources, you must proceed in the reverse order.

1.  **Destroy the main infrastructure.**

    ```bash
    cd terraform-modules-vpc-s3
    terraform destroy --auto-approve
    cd ..
    ```

2.  **Destroy the backend infrastructure.**

    ```bash
    cd terraform-backend-setup
    terraform destroy --auto-approve
    cd ..
    ```

take note

## 2. Create the S3 Bucket for Terraform Backend

Before we start writing the code, we need to create an S3 bucket to store the Terraform state file. This has to be done manually or with a separate, simple Terraform configuration, because the backend is configured before any resources are created.

**For this exercise, we will create it manually using the AWS CLI.**

1.  **Choose a unique bucket name.** Bucket names must be globally unique. We'll use `daretechie-devops-tf-state-bucket` as an example. Replace it with your own unique name.
2.  **Create the S3 bucket.**

    ```bash
    aws s3api create-bucket --bucket daretechie-devops-tf-state-bucket --region us-east-1
    ```

3.  **Enable versioning on the bucket** to keep the history of your state file.

    ```bash
    aws s3api put-bucket-versioning --bucket daretechie-devops-tf-state-bucket --versioning-configuration Status=Enabled
    ```

4.  **Create a DynamoDB table for state locking.** This is a best practice to prevent concurrent runs of Terraform from corrupting your state.

    ```bash
    aws dynamodb create-table \
        --table-name terraform-lock \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
    ```

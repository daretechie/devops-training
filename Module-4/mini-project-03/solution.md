# Mini-Project 3: Comprehensive Guide to Terraform Modules and Backends

This guide provides a detailed, beginner-friendly walkthrough for setting up a remote backend and provisioning infrastructure using Terraform modules. It addresses common issues and incorporates best practices for a successful project submission.

## Table of Contents

1.  [Project Overview](#1-project-overview)
2.  [Prerequisites](#2-prerequisites)
3.  [Step 1: Verify AWS Authentication](#3-step-1-verify-aws-authentication)
4.  [Step 2: Set Up the Terraform Backend Manually](#4-step-2-set-up-the-terraform-backend-manually)
5.  [Step 3: Configure the Terraform Project](#5-step-3-configure-the-terraform-project)
6.  [Step 4: Provision the Infrastructure](#6-step-4-provision-the-infrastructure)
7.  [Step 5: Clean Up Resources](#7-step-5-clean-up-resources)
8.  [Troubleshooting Common Errors](#8-troubleshooting-common-errors)
9.  [Recommended `.gitignore` Configuration](#9-recommended-gitignore-configuration)
10. [Side Note: `terraform apply --auto-approve`](#10-side-note-terraform-apply---auto-approve)

---

### 1. Project Overview

The goal of this project is to demonstrate proficiency with two core Terraform concepts:

*   **Remote State Management:** Using an S3 bucket and a DynamoDB table as a remote backend to securely store and lock the Terraform state file. This is crucial for collaborative environments.
*   **Terraform Modules:** Structuring your infrastructure code into reusable modules for a VPC and an S3 bucket to promote organization and code reuse.

We will provision a new VPC and an S3 bucket with advanced features like versioning, logging, and lifecycle policies.

### 2. Prerequisites

Before you begin, ensure you have the following:

*   **AWS Account:** An active AWS account with programmatic access (Access Key ID and Secret Access Key).
*   **AWS CLI:** The AWS Command Line Interface installed and configured. You can test your configuration with `aws configure list`.
*   **Terraform:** Terraform installed on your local machine. You can verify the installation with `terraform --version`.

### 3. Step 1: Verify AWS Authentication

It is critical to confirm that your AWS CLI is correctly authenticated before running any commands. This ensures that Terraform can interact with your AWS account.

Run the following command:

```bash
aws sts get-caller-identity
```

**Expected Output:**

The output should show your AWS Account ID, User ID, and ARN.

```json
{
    "UserId": "AIDA...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/your-user-name"
}
```

**Action Required:** Take a screenshot of the command and its output. This will be part of your submission to prove you are authenticated.

![aws-sts-get-caller-identity](img/aws-sts-get-caller-identity.png)

### 4. Step 2: Set Up the Terraform Backend Manually

Terraform needs a backend to store its state file. When working in a team, this backend must be remote (i.e., not on your local machine). We use an S3 bucket for storage and a DynamoDB table for state locking to prevent concurrent modifications.

These resources must be created *before* you initialize the main Terraform project that will use them. For this project, we will create them manually via the AWS CLI.

1.  **Choose a Unique S3 Bucket Name:** Bucket names are globally unique. For this guide, we use `daretechie-devops-tf-state-bucket`, but you **must replace this with your own unique name**.

2.  **Create the S3 Bucket:**

    ```bash
    aws s3api create-bucket --bucket daretechie-devops-tf-state-bucket --region us-east-1
    ```

3.  **Enable Versioning:** This is a best practice to keep a history of your state files, allowing you to revert to a previous state if necessary.

    ```bash
    aws s3api put-bucket-versioning --bucket daretechie-devops-tf-state-bucket --versioning-configuration Status=Enabled
    ```

4.  **Create the DynamoDB Table for State Locking:**

    ```bash
    aws dynamodb create-table \
        --table-name terraform-lock \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
    ```

**Action Required:** Take a screenshot of the successful creation of these resources.

![backend-setup](img/backend-setup.png)

### 5. Step 3: Configure the Terraform Project

Now, navigate to the main project directory and prepare the Terraform files.

```bash
cd /home/daretechie/DevProject/GitHub/devops-training/Module-4/mini-project-03/terraform-modules-vpc-s3
```

#### a. Fix Module Paths

The error `Invalid module source address` occurs because Terraform requires a `./` prefix for local paths. Correct the `source` arguments in `main.tf`.

**File:** `main.tf`

```terraform
module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = "daretechie-devops-unique-bucket-for-hosting"
}
```

#### b. Configure the Backend

Your `backend.tf` file tells Terraform where to store the state. **Make sure the bucket name matches the one you created manually.**

**File:** `backend.tf`

```terraform
terraform {
  backend "s3" {
    bucket         = "daretechie-devops-tf-state-bucket" # Use your unique bucket name here
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}
```

### 6. Step 4: Provision the Infrastructure

With the configuration corrected, you can now initialize Terraform, review the plan, and apply it.

1.  **Initialize Terraform:** This command downloads the necessary providers and configures the backend.

    ```bash
    terraform init
    ```

    You should see a message "Successfully configured the backend \"s3\"" and "Terraform has been successfully initialized!".

2.  **Plan the Changes:** This command shows you what resources Terraform will create, change, or destroy.

    ```bash
    terraform plan
    ```

3.  **Apply the Changes:** This command executes the plan and builds the infrastructure.

    ```bash
    terraform apply
    ```

    Terraform will ask for confirmation. Type `yes` and press Enter.

**Action Required:** Take a screenshot of the successful `terraform apply` output, showing the resources created.

![terraform-apply-output](img/terraform-apply-output.png)

### 7. Step 5: Clean Up Resources

A critical part of infrastructure management is cleaning up resources you no longer need to avoid incurring costs.

1.  **Destroy Terraform-Managed Resources:**

    ```bash
    terraform destroy
    ```

    Confirm the action by typing `yes`.

    **Action Required:** Take a screenshot of the successful `terraform destroy` output.

    ![terraform-destroy-output](img/terraform-destroy-output.png)

2.  **Manually Delete Backend Resources:** The S3 bucket and DynamoDB table were created manually, so they must be deleted manually.

    *   **Empty and Delete the S3 Bucket:**

        ```bash
        aws s3 rb s3://daretechie-devops-tf-state-bucket --force
        ```

    *   **Delete the DynamoDB Table:**

        ```bash
        aws dynamodb delete-table --table-name terraform-lock
        ```

### 8. Troubleshooting Common Errors

*   **Error:** `Invalid module source address`
    *   **Cause:** The `source` path for a local module in `main.tf` is missing the `./` prefix.
    *   **Solution:** Change `source = "modules/vpc"` to `source = "./modules/vpc"`.

*   **Error:** `S3 bucket "..." does not exist`
    *   **Cause:** You ran `terraform init` before creating the S3 bucket for the backend, or there is a typo in the bucket name in `backend.tf`.
    *   **Solution:** Ensure you have manually created the S3 bucket and that the name in `backend.tf` is correct.

*   **Error:** `creating S3 Bucket (...): BucketAlreadyExists`
    *   **Cause:** This happens if your Terraform configuration attempts to create an S3 bucket that already exists. This is common if you try to manage your backend bucket with the same Terraform code that uses it as a backend.
    *   **Solution:** Backend resources should be managed completely separately from your main infrastructure configuration. By creating them manually as we did, you avoid this circular dependency.

### 9. Recommended `.gitignore` Configuration

To keep your repository clean and secure, you should prevent Terraform state files and other temporary files from being committed. Your `.gitignore` file should contain:

```gitignore
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log

# Exclude all .tfvars files, which are likely to contain sensitive data,
# unless the user explicitly commits them.
*.tfvars
*.tfvars.json

# Ignore override files as they are usually used for local testing
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# TFLint files
.tflint.hcl

# Terraform lock file
.terraform.lock.hcl
```

### 10. Side Note: `terraform apply --auto-approve`

The `--auto-approve` flag is used to skip the interactive confirmation step during `terraform apply`. While this is useful for automation (like in a CI/CD pipeline where no user is present to type "yes"), it should be **used with caution**. In a production environment, you should always run `terraform plan` and have a human review the changes before applying them. Manual approval is a critical safety check.
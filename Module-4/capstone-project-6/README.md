# Capstone Project: Modular EC2 Deployment with Apache using Terraform

## 1. Introduction

This project demonstrates how to provision an AWS EC2 instance with an Apache web server using a modular Terraform configuration. The primary goal is to showcase best practices in infrastructure as code (IaC), including reusability, modularity, and automation.

This guide is designed for DevOps Engineers, Cloud Architects, and IT professionals who want to learn how to create flexible and reusable infrastructure components with Terraform.

![Apache Test Page](img/apache-test-page.png)

## 2. Project Structure

The project is organized into modules to promote reusability and separation of concerns.

```
.
├── main.tf              # Main configuration to integrate modules
├── modules/
│   ├── ec2/             # EC2 instance module
│   │   ├── main.tf
│   │   └── variables.tf
│   └── security-group/  # Security group module
│       ├── main.tf
│       └── variables.tf
└── user-data/
    └── setup-apache.sh  # Script to install and start Apache
```

- **`main.tf`**: The entry point of our Terraform configuration. It defines the provider, and calls the `ec2` and `security-group` modules, passing the required variables to provision the resources.
- **`modules/ec2/`**: A reusable module responsible for creating the EC2 instance.
- **`modules/security-group/`**: A reusable module for creating a security group with inbound rules.
- **`user-data/setup-apache.sh`**: A shell script that runs on the EC2 instance at launch to install and start the Apache web server.

## 3. Prerequisites

Before you begin, ensure you have the following:

- An **AWS Account** with the necessary permissions to create EC2 instances and Security Groups.
- **Terraform** installed on your local machine (version 1.0.0 or higher).
- **AWS CLI** installed and configured with your credentials. You can configure this by running `aws configure`.

## 4. Deployment Steps

Follow these steps to deploy the infrastructure.

### Step 1: Clone the Repository

Clone this repository to your local machine.

```bash
git clone <repository-url>
cd <repository-directory>/Module-4/capstone-project-6
```

### Step 2: Initialize Terraform

Run the `terraform init` command to initialize the working directory. This will download the necessary provider plugins and modules.

```bash
terraform init
```

You should see a message indicating that Terraform has been successfully initialized.

![Terraform Init](img/terraform-init.png)

### Step 3: Review the Execution Plan

Run `terraform plan` to create an execution plan. This will show you what resources Terraform will create, modify, or destroy.

```bash
terraform plan
```

Review the plan carefully to ensure it matches your expectations.

![Terraform Plan](img/terraform-plan.png)

### Step 4: Apply the Configuration

Apply the Terraform configuration to create the resources in your AWS account.

```bash
terraform apply -auto-approve
```

Terraform will now provision the EC2 instance and the security group. The output will display the public IP address of the EC2 instance.

![Terraform Apply](img/terraform-apply.png)

### Step 5: Verify the Deployment

Open your web browser and navigate to the public IP address of the EC2 instance. You should see the default Apache test page.

```
http://<your-ec2-public-ip>
```

This confirms that the EC2 instance was launched successfully and the user data script executed correctly.

## 5. Refactoring and Improving the Project

This section addresses the feedback from the project review and provides guidance on how to improve the existing Terraform code for better flexibility, security, and collaboration.

### 5.1. Refactor the EC2 Module

#### Using `vpc_security_group_ids`

**Problem**: The EC2 module uses `security_groups = [var.security_group_id]`, which is intended for EC2-Classic. For instances in a VPC, `vpc_security_group_ids` is the recommended attribute.

**Solution**: Modify the `aws_instance` resource in `modules/ec2/main.tf`.

**`modules/ec2/main.tf` (Before)**
```terraform
resource "aws_instance" "web" {
  # ...
  security_groups = [var.security_group_id]
  # ...
}
```

**`modules/ec2/main.tf` (After)**
```terraform
resource "aws_instance" "web" {
  # ...
  vpc_security_group_ids = [var.security_group_id]
  # ...
}
```

This change aligns the module with modern AWS best practices for VPC resources.

#### Dynamic AMI IDs

**Problem**: The AMI ID is hardcoded in the variables, which limits the module's reusability across different AWS regions.

**Solution**: Use a data source to dynamically fetch the latest Amazon Linux 2 AMI for the specified region.

**Add to `modules/ec2/main.tf`**
```terraform
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
```

Then, update the `aws_instance` resource to use this data source.

```terraform
resource "aws_instance" "web" {
  ami           = data.aws_ami.latest_amazon_linux.id
  # ...
}
```
You can now remove the hardcoded `ami_id` variable.

### 5.2. Refactor the Security Group Module

**Problem**: The security group module has hardcoded values for CIDR blocks and ports, making it less reusable.

**Solution**: Introduce variables for `cidr_blocks`, `from_port`, `to_port`, and `protocol`.

**`modules/security-group/variables.tf` (Additions)**
```terraform
variable "ingress_cidr_blocks" {
  description = "List of CIDR blocks for ingress rule"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ingress_from_port" {
  description = "The from port for the ingress rule"
  type        = number
  default     = 80
}

variable "ingress_to_port" {
  description = "The to port for the ingress rule"
  type        = number
  default     = 80
}

variable "ingress_protocol" {
  description = "The protocol for the ingress rule"
  type        = string
  default     = "tcp"
}
```

**`modules/security-group/main.tf` (Update)**
```terraform
resource "aws_security_group" "web_sg" {
  # ...
  ingress {
    from_port   = var.ingress_from_port
    to_port     = var.ingress_to_port
    protocol    = var.ingress_protocol
    cidr_blocks = var.ingress_cidr_blocks
  }
  # ...
}
```

### 5.3. Refine the UserData Script

**Problem**: The `setup-apache.sh` script is basic and lacks error handling and validation.

**Solution**: Enhance the script to check if Apache (`httpd`) is installed correctly and to log the output.

**`user-data/setup-apache.sh` (Improved)**
```bash
#!/bin/bash
# Log everything to a file
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting user data script..."

# Update and install Apache
yum update -y
yum install -y httpd

# Check if httpd was installed successfully
if ! [ -x "$(command -v httpd)" ]; then
  echo "Error: httpd failed to install." >&2
  exit 1
fi

echo "httpd installed successfully."

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Check if httpd is running
systemctl status httpd
echo "Apache setup complete."
```

### 5.4. Enhance Flexibility and Collaboration

#### Create a `variables.tf` File

**Problem**: The project lacks a central `variables.tf` file to manage common inputs.

**Solution**: Create a `variables.tf` file in the root directory to define variables like `region` and `instance_type`.

**`variables.tf` (Root Directory)**
```terraform
variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t2.micro"
}
```

Update `main.tf` to use these variables when calling the modules.

#### Implement Remote State Storage (S3 Backend)

**Problem**: Storing Terraform state locally (`terraform.tfstate`) is not suitable for team collaboration.

**Solution**: Configure an S3 backend to store the state file remotely.

**1. Create an S3 Bucket**: Create an S3 bucket in your AWS account to store the state file.

**2. Add Backend Configuration to `main.tf`**:
```terraform
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket-name" # CHANGE THIS
    key    = "capstone-project-6/terraform.tfstate"
    region = "us-east-1"
  }
}
```
After adding this, you will need to re-run `terraform init`.

### 5.5. Improve Security Practices

**Problem**: The security group allows traffic from all IPs (`0.0.0.0/0`), which is a security risk.

**Solution**: Implement IP whitelisting by restricting access to your IP address.

You can get your current IP address and pass it to Terraform.

**`main.tf` (Update)**
```terraform
module "security_group" {
  source = "./modules/security-group"
  # ...
  ingress_cidr_blocks = ["YOUR_IP_ADDRESS/32"] # Replace with your IP
}
```
For a more dynamic approach, you can use a data source to fetch your IP.

## 6. Cleaning Up

To destroy all the resources created by this project, run the `terraform destroy` command.

```bash
terraform destroy -auto-approve
```

This will remove the EC2 instance and the security group from your AWS account.

## 7. Conclusion

This project provided hands-on experience with creating modular and reusable Terraform configurations. By completing the deployment and the refactoring exercises, you have improved the project's flexibility, security, and adherence to best practices, making it more robust and suitable for real-world scenarios.

# Terraform EC2 and Security Group Modules with Apache2

This project guides you through creating a modular Terraform configuration to deploy an EC2 instance with a web server (Apache2) automatically installed and configured.

## 📦 Introduction

In this project, you will learn how to structure your Terraform code into reusable modules. This is a best practice for managing infrastructure as code, making your configurations more organized, scalable, and easier to maintain.

We will create two main modules:
- **EC2 Module**: Responsible for creating the EC2 instance.
- **Security Group Module**: Responsible for defining the firewall rules for our EC2 instance.

We will also use a `UserData` script to automatically install and configure Apache2 on the EC2 instance upon launch.

![Project Architecture](img/project-architecture.png)

## 🎯 Project Goals

- Understand and implement Terraform modules.
- Create a reusable EC2 module.
- Create a reusable Security Group module.
- Use `UserData` to bootstrap an EC2 instance with a web server.
- Deploy and verify a web server running on AWS.

## 🛠️ Prerequisites

Before you begin, ensure you have the following:

- **AWS Account**: An active AWS account with the necessary permissions to create EC2 instances and Security Groups.
- **AWS CLI**: The AWS Command Line Interface installed and configured with your credentials. You can check your configuration by running `aws configure list`.
- **Terraform**: Terraform installed on your local machine. You can verify the installation by running `terraform --version`.
- **Basic Linux Knowledge**: Familiarity with basic Linux commands.

## 📂 Project Structure

First, let's set up the directory structure for our project.

### 1. Create the Project Directory

Open your terminal and create a directory for the project:

```bash
mkdir terraform-ec2-apache
cd terraform-ec2-apache
```

### 2. Create the Module Directories

Inside the `terraform-ec2-apache` directory, create directories for your modules:

```bash
mkdir -p modules/ec2
mkdir -p modules/security_group
```

Your project structure should now look like this:

```
terraform-ec2-apache/
├── modules/
│   ├── ec2/
│   └── security_group/
└── main.tf
```

## 🚀 Step-by-Step Guide

### Step 1: Create the Security Group Module

This module will define a security group that allows inbound traffic on port 80 (HTTP) and port 22 (SSH).

Create a file named `main.tf` inside the `modules/security_group` directory:

```bash
nano modules/security_group/main.tf
```

Add the following code to the file:

```terraform
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Allow HTTP and SSH traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "security_group_id" {
  value = aws_security_group.web_sg.id
}
```

![Security Group Module Code](img/security-group-module.png)

### Step 2: Create the EC2 Instance Module

This module will define the EC2 instance. It will use the security group created in the previous step.

Create a file named `main.tf` inside the `modules/ec2` directory:

```bash
nano modules/ec2/main.tf
```

Add the following code to the file:

```terraform
variable "instance_type" {
  description = "The type of EC2 instance to launch."
  default     = "t2.micro"
}

variable "ami_id" {
  description = "The AMI to use for the EC2 instance."
  default     = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
}

variable "security_group_id" {
  description = "The ID of the security group to associate with the EC2 instance."
}

variable "user_data" {
  description = "The user data script to run on instance launch."
}

resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  security_groups = [var.security_group_id]
  user_data     = var.user_data

  tags = {
    Name = "My-Web-Server"
  }
}

output "public_ip" {
  value = aws_instance.web_server.public_ip
}
```

![EC2 Module Code](img/ec2-module.png)

### Step 3: Create the UserData Script

This script will be executed when the EC2 instance starts. It will update the system, install Apache, and create a simple `index.html` file.

Create a file named `apache_userdata.sh` in the root of your project directory:

```bash
nano apache_userdata.sh
```

Add the following script to the file:

```bash
#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<h1>Hello World from $(hostname -f)</h1>" | sudo tee /var/www/html/index.html
```

Make the script executable:

```bash
chmod +x apache_userdata.sh
```

![UserData Script](img/userdata-script.png)

### Step 4: Create the Main Terraform Configuration

This is the main file that will bring everything together. It will use the modules we created to deploy the infrastructure.

Create a file named `main.tf` in the root of your project directory:

```bash
nano main.tf
```

Add the following code to the file:

```terraform
provider "aws" {
  region = "us-east-1" # Change to your preferred region
}

module "security_group" {
  source = "./modules/security_group"
}

module "ec2_instance" {
  source            = "./modules/ec2"
  security_group_id = module.security_group.security_group_id
  user_data         = file("apache_userdata.sh")
}

output "instance_public_ip" {
  value = module.ec2_instance.public_ip
}
```

![Main Terraform Configuration](img/main-tf.png)

### Step 5: Deploy the Infrastructure

Now we are ready to deploy our infrastructure.

1.  **Initialize Terraform**:
    This command will download the necessary provider plugins.

    ```bash
    terraform init
    ```

    ![Terraform Init Output](img/terraform-init.png)

2.  **Plan the Deployment**:
    This command will show you what resources Terraform will create.

    ```bash
    terraform plan
    ```

    ![Terraform Plan Output](img/terraform-plan.png)

3.  **Apply the Changes**:
    This command will create the resources in your AWS account.

    ```bash
    terraform apply --auto-approve
    ```

    ![Terraform Apply Output](img/terraform-apply.png)

### Step 6: Verify the Deployment

Once the `terraform apply` command is complete, it will output the public IP address of your EC2 instance.

1.  **Copy the Public IP**:
    Copy the `instance_public_ip` from the output.

2.  **Access the Web Server**:
    Open your web browser and navigate to the public IP address. You should see the "Hello World" message from your Apache server.

    `http://<your-instance-public-ip>`

    ![Web Server Verification](img/web-server-verification.png)

3.  **SSH into the Instance (Optional)**:
    You can also SSH into the instance to verify that Apache is running.

    ```bash
    ssh -i "your-key.pem" ec2-user@<your-instance-public-ip>
    ```

    Check the status of the httpd service:

    ```bash
    sudo systemctl status httpd
    ```

    ![SSH Verification](img/ssh-verification.png)

## 🧹 Clean Up

To avoid incurring unnecessary costs, it's important to destroy the resources you've created.

Run the following command to destroy all the resources managed by this Terraform configuration:

```bash
terraform destroy --auto-approve
```

![Terraform Destroy Output](img/terraform-destroy.png)

## 🐞 Troubleshooting

| Problem                                     | Cause                                           | Solution                                                                                                                                                              |
| ------------------------------------------- | ----------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Connection Timed Out** when accessing the web server | Security group is not configured correctly.     | Double-check your security group module to ensure that inbound traffic on port 80 is allowed from `0.0.0.0/0`.                                                      |
| **Terraform complains about missing provider**     | You haven't run `terraform init`.               | Run `terraform init` in your project's root directory to download the necessary provider plugins.                                                                   |
| **EC2 instance doesn't have a public IP**      | The subnet you are deploying to does not assign public IPs. | Ensure that the "Auto-assign public IPv4 address" setting is enabled for the subnet you are deploying to. You can also explicitly associate an Elastic IP. |
| **Apache is not running**                     | There was an error in the `UserData` script.    | SSH into the instance and check the cloud-init logs at `/var/log/cloud-init-output.log` for any errors.                                                              |

## 💡 Further Exploration

Here are some ideas to expand on this project:

- **Use Variables**: Make your modules more flexible by using variables for things like the instance type, AMI, and security group rules.
- **Add a Load Balancer**: Create another module for an Application Load Balancer to distribute traffic to multiple EC2 instances.
- **More Complex UserData**: Deploy a more complex application, such as a Node.js or Python web application.
- **Remote State**: Configure Terraform to store its state file in an S3 bucket for better collaboration and state management.

## 📜 Conclusion

Congratulations! You have successfully created a modular Terraform project to deploy an EC2 instance with a web server. This project has taught you the fundamentals of Terraform modules, which are essential for building scalable and maintainable infrastructure as code.

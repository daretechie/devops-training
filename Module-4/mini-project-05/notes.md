Mini Project: EC2 Module and Security Group Module with Apache2 UserData
Purpose:
In this mini project, you will use Terraform to create modularized configurations for deploying an EC2 instance with a specified Security Group and Apache2 installed using UserData.

Objectives:
Terraform Module Creation:

Learn how to create Terraform modules for modular infrastructure provisioning.
EC2 Instance Configuration:

Configure Terraform to create an EC2 instance.
Security Group Configuration:

Create a separate module for the Security Group associated with the EC2 instance.
UserData Script:

Utilize UserData to install and configure Apache2 on the EC2 instance.
Project Tasks:
Task 1: EC2 Module
Create a new directory for your Terraform project (e.g., terraform-ec2-apache).

Inside the project directory, create a directory for the EC2 module (e.g., modules/ec2).

Write a Terraform module (modules/ec2/main.tf) to create an EC2 instance.

Task 2: Security Group Module
Inside the project directory, create a directory for the Security Group module (e.g., modules/security_group).

Write a Terraform module (modules/security_group/main.tf) to create a Security Group for the EC2 instance.

Task 3: UserData Script
Write a UserData script to install and configure Apache2 on the EC2 instance. Save it as a separate file (e.g., apache_userdata.sh).

Ensure that the UserData script is executable (chmod +x apache_userdata.sh).

Task 4: Main Terraform Configuration
Create the main Terraform configuration file (main.tf) in the project directory.

Use the EC2 and Security Group modules to create the necessary infrastructure for the EC2 instance.

Task 5: Deployment
Run terraform init and terraform apply to deploy the EC2 instance with Apache2.

Access the EC2 instance and verify that Apache2 is installed and running.

Instructions:
Create a new directory for your Terraform project using a terminal (mkdir terraform-ec2-apache).

Change into the project directory (cd terraform-ec2-apache).

Create directories for the EC2 and Security Group modules (mkdir -p modules/ec2 and mkdir -p modules/security_group).

Write the EC2 module configuration (nano modules/ec2/main.tf) to create an EC2 instance.

Write the Security Group module configuration (nano modules/security_group/main.tf) to create a Security Group.

Write the UserData script (nano apache_userdata.sh) to install and configure Apache2.

Copy
#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<h1>Hello World from $(hostname -f)</h1>" | sudo tee /var/www/html/index.html
Make the UserData script executable (chmod +x apache_userdata.sh).

Create the main Terraform configuration file (nano main.tf) and use the EC2 and Security Group modules.

Copy
module "security_group" {"\n source = \"./modules/security_group\"\n // Add variables for customizing the Security Group if needed\n"}

module "ec2_instance" {"\n source = \"./modules/ec2\"\n security_group_id = module.security_group.security_group_id\n user_data = file(\"apache_userdata.sh\")\n // Add other variables as needed\n"}
Run terraform init and terraform apply to deploy the EC2 instance with Apache2.

Access the EC2 instance using its public IP and verify that Apache2 is installed and running.

Document your observations and any challenges faced during the project.

Side Note:

Copy

- Ensure you have the AWS CLI installed and configured with appropriate credentials.
- Modify variables and configurations in the modules based on your specific requirements.
- This is a learning exercise; use it to gain hands-on experience with Terraform, EC2, UserData, and Security Groups.

Previous step
Hosting a Dynamic Web App on AWS with Terraform Module, Docker, ECR, and ECS

Next step
Automated WordPress deployment on AWS
On this page:

EC2 Module and Security Group Module with Apache2 UserData

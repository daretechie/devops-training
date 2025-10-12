Terraform Capstone Project: Automated WordPress Deployment on AWS
Project Scenario
DigitalBoost, a digital marketing agency, aims to elevate its online presence by launching a high-performance WordPress website for their clients. As an AWS Solutions Architect, your task is to design and implement a scalable, secure, and cost-effective WordPress solution using various AWS services. Automation through Terraform will be key to achieving a streamlined and reproducible deployment process.

Pre-requisite
Knowledge of TechOps Essentials
Completion of Core 2 Courses and Mini Projects
The project overview, necessary architecture, and scripts have been provided to help DigitalBoost with their WordPress-based website. Follow the instructions below to complete this Terraform Capstone Project.

Project Deliverables
Documentation:

Detailed documentation for each component setup.
Explanation of security measures implemented.
Demonstration:

Live demonstration of the WordPress site.
Showcase auto-scaling by simulating increased traffic.
Project Overview
Project Architecture

Project Components

1. VPC Setup
   VPC ARCHITECTURE
   VPC Architecture

Objective: Create a Virtual Private Cloud (VPC) to isolate and secure the WordPress infrastructure.

Steps:

Define IP address range for the VPC.
Create VPC with public and private subnets.
Configure route tables for each subnet.
Instructions for Terraform:

Use Terraform to define VPC, subnets, and route tables.
Leverage variables for customization.
Document Terraform commands for execution. 2. Public and Private Subnet with NAT Gateway
NAT GATEWAY ARCHITECTURE
Nat Gateway Architecture

Objective: Implement a secure network architecture with public and private subnets. Use a NAT Gateway for private subnet internet access.

Steps:

Set up a public subnet for resources accessible from the internet.
Create a private subnet for resources with no direct internet access.
Configure a NAT Gateway for private subnet internet access.
Instructions for Terraform:

Utilize Terraform to define subnets, security groups, and NAT Gateway.
Ensure proper association of resources with corresponding subnets.
Document Terraform commands for execution. 3. AWS MySQL RDS Setup
SECURITY GROUP ARCHITECTURE
Security Group Architecture

Objective: Deploy a managed MySQL database using Amazon RDS for WordPress data storage.

Steps:

Create an Amazon RDS instance with the MySQL engine.
Configure security groups for the RDS instance.
Connect WordPress to the RDS database.
Instructions for Terraform:

Define Terraform scripts for RDS instance creation.
Configure security groups and define necessary parameters.
Document Terraform commands for execution. 4. EFS Setup for WordPress Files
Objective: Utilize Amazon Elastic File System (EFS) to store WordPress files for scalable and shared access.

Steps:

Create an EFS file system.
Mount the EFS file system on WordPress instances.
Configure WordPress to use the shared file system.
Instructions for Terraform:

Develop Terraform scripts to create EFS file system.
Define configurations for mounting EFS on WordPress instances.
Document Terraform commands for execution. 5. Application Load Balancer
Objective: Set up an Application Load Balancer to distribute incoming traffic among multiple instances, ensuring high availability and fault tolerance.

Steps:

Create an Application Load Balancer.
Configure listener rules for routing traffic to instances.
Integrate Load Balancer with Auto Scaling group.
Instructions for Terraform:

Use Terraform to define Application Load Balancer configurations.
Integrate Load Balancer with Auto Scaling group.
Document Terraform commands for execution. 6. Auto Scaling Group
Objective: Implement Auto Scaling to automatically adjust the number of instances based on traffic load.

Steps:

Create an Auto Scaling group.
Define scaling policies based on metrics like CPU utilization.
Configure launch configurations for instances.
Instructions for Terraform:

Develop Terraform scripts for Auto Scaling group creation.
Define scaling policies and launch configurations.
Document Terraform commands for execution.
Note: Provide thorough documentation for each Terraform script and include necessary variable configurations. Encourage students to perform a live demonstration of the WordPress site, showcasing auto-scaling capabilities by simulating increased traffic. The documentation should explain the security measures implemented at each step.

Previous step
EC2 Module and Security Group Module with Apache2 UserData

Next step
Automating Server

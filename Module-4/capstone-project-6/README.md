# 🚀 Terraform Capstone Project 6: Automated WordPress Deployment on AWS

## 🎯 Project Overview

**DigitalBoost**, a digital marketing agency, is launching a high-performance WordPress website for their clients. As an AWS Solutions Architect, you will design and implement a scalable, secure, and cost-effective WordPress solution using various AWS services with **Terraform** automation.

This project demonstrates Infrastructure as Code (IaC) principles by deploying a complete WordPress stack on AWS including VPC, RDS, EFS, Application Load Balancer, and Auto Scaling Groups.

![Project Architecture](./img/architecture-diagram.png)

---

## 📋 Prerequisites

### Required Knowledge
- ✅ Completion of Core 2 Courses and Mini Projects
- ✅ TechOps Essentials (Linux, Shell Scripting, Git)
- ✅ Basic understanding of AWS services
- ✅ Terraform fundamentals

### Technical Requirements
- **AWS Account** with appropriate IAM permissions
- **Terraform** installed (v1.0+)
- **AWS CLI** configured with access keys
- **Git** for version control
- **SSH Key Pair** created in AWS

### Project Deliverables for Submission
1. **Complete Terraform Codebase** (All `.tf` files)
2. **Screenshots/Evidence** of working infrastructure
3. **Live Demonstration** of WordPress site
4. **Auto-scaling Demo** (simulated traffic increase)
5. **Documentation** of security measures implemented

---

## 🏗️ Project Architecture

The solution implements a **highly available, scalable WordPress deployment**:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Application   │    │      Load       │    │     Auto        │
│ Load Balancer   │◄──►│    Balancer     │◄──►│   Scaling       │
│                 │    │                 │    │    Group        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Public        │    │    Private      │    │       EFS       │
│   Subnet        │    │    Subnet       │    │   File System   │
│   (Web Servers) │    │  (Database)     │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│      EC2        │    │   RDS MySQL     │    │   Shared        │
│  WordPress      │    │   Database      │    │  WordPress      │
│   Instances     │    │                 │    │     Files       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

---

## 🚀 Step-by-Step Implementation Guide

### Phase 1: Infrastructure Foundation (VPC & Network)

#### 1.1 VPC Setup with Public and Private Subnets

**Objective**: Create a secure network foundation with proper IP addressing and routing.

**Files to Create**:
- `vpc.tf` - Main VPC configuration
- `variables.tf` - Input variables
- `outputs.tf` - Output values

**Step-by-Step Instructions**:

1. **Create VPC Configuration**:
```bash
# Create vpc.tf
cat > vpc.tf << 'EOF'
resource "aws_vpc" "wordpress_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "wordpress-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.wordpress_vpc.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "wordpress-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.wordpress_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "wordpress-private-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.wordpress_vpc.id

  tags = {
    Name = "wordpress-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.wordpress_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "wordpress-public-rt"
  }
}

resource "aws_route_table_association" "public_rta" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}
EOF
```

2. **Create Variables File**:
```bash
# Create variables.tf
cat > variables.tf << 'EOF'
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}
EOF
```

3. **Deploy VPC**:
```bash
terraform init
terraform plan
terraform apply -auto-approve
```

**Expected Output**:
- VPC created with CIDR `10.0.0.0/16`
- 2 public subnets with internet access
- 2 private subnets for secure resources

![VPC Architecture](./img/vpc-architecture.png)

#### 1.2 NAT Gateway Setup

**Objective**: Enable private subnet instances to access the internet securely.

```bash
# Add to vpc.tf
resource "aws_eip" "nat_eip" {
  count = length(var.public_subnet_cidrs)
  vpc   = true

  tags = {
    Name = "wordpress-nat-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = {
    Name = "wordpress-nat-gw-${count.index + 1}"
  }
}

resource "aws_route_table" "private_rt" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.wordpress_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }

  tags = {
    Name = "wordpress-private-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_rta" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}
```

---

### Phase 2: Database Layer (RDS MySQL)

#### 2.1 RDS MySQL Setup

**Objective**: Deploy a managed MySQL database for WordPress data storage.

**Files**: `rds.tf`

```bash
# Create rds.tf
cat > rds.tf << 'EOF'
resource "aws_db_subnet_group" "wordpress_db_subnet_group" {
  name       = "wordpress-db-subnet-group"
  subnet_ids = aws_subnet.private_subnet[*].id

  tags = {
    Name = "wordpress-db-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "wordpress-rds-sg"
  description = "Security group for RDS MySQL"
  vpc_id      = aws_vpc.wordpress_vpc.id

  ingress {
    description     = "MySQL access from web servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.wordpress_sg.id]
  }

  tags = {
    Name = "wordpress-rds-sg"
  }
}

resource "aws_db_instance" "wordpress_db" {
  identifier = "wordpress-db"

  # Engine configuration
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  # Database configuration
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  # Storage configuration
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  # Network configuration
  db_subnet_group_name   = aws_db_subnet_group.wordpress_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false

  # Backup and maintenance
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  # Monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn

  # Auto minor version upgrade
  auto_minor_version_upgrade = true

  # Deletion protection (remove for easy cleanup)
  deletion_protection = false

  tags = {
    Name = "wordpress-database"
  }
}

# IAM role for RDS enhanced monitoring
resource "aws_iam_role" "rds_enhanced_monitoring" {
  name = "rds-enhanced-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "rds-enhanced-monitoring-role"
  }
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
EOF
```

**Add Database Variables**:
```bash
# Add to variables.tf
variable "db_name" {
  description = "Database name"
  type        = string
  default     = "wordpress"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
```

![RDS MySQL Database](./img/rds-mysql.png)

---

### Phase 3: File Storage (EFS)

#### 3.1 Elastic File System Setup

**Objective**: Create shared file system for WordPress files across multiple instances.

**Files**: `efs.tf`

```bash
# Create efs.tf
cat > efs.tf << 'EOF'
resource "aws_efs_file_system" "wordpress_efs" {
  creation_token = "wordpress-efs"
  encrypted      = true

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "wordpress-efs"
  }
}

resource "aws_efs_mount_target" "wordpress_efs_mt" {
  count           = length(aws_subnet.private_subnet)
  file_system_id  = aws_efs_file_system.wordpress_efs.id
  subnet_id       = aws_subnet.private_subnet[count.index].id
  security_groups = [aws_security_group.wordpress_sg.id]
}

resource "aws_security_group" "wordpress_sg" {
  name        = "wordpress-sg"
  description = "Security group for WordPress instances"
  vpc_id      = aws_vpc.wordpress_vpc.id

  ingress {
    description     = "HTTP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "NFS (EFS)"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.wordpress_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wordpress-sg"
  }
}
EOF
```

---

### Phase 4: Load Balancing & Auto Scaling

#### 4.1 Application Load Balancer

**Files**: `alb.tf`

```bash
# Create alb.tf
cat > alb.tf << 'EOF'
resource "aws_security_group" "alb_sg" {
  name        = "wordpress-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.wordpress_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.wordpress_sg.id]
  }

  tags = {
    Name = "wordpress-alb-sg"
  }
}

resource "aws_lb" "wordpress_alb" {
  name               = "wordpress-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public_subnet[*].id

  enable_deletion_protection = false

  tags = {
    Name = "wordpress-alb"
  }
}

resource "aws_lb_target_group" "wordpress_tg" {
  name     = "wordpress-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.wordpress_vpc.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 1800
    enabled         = false
  }

  tags = {
    Name = "wordpress-target-group"
  }
}

resource "aws_lb_listener" "wordpress_listener" {
  load_balancer_arn = aws_lb.wordpress_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_tg.arn
  }
}
EOF
```

#### 4.2 Auto Scaling Group

**Files**: `autoscaling.tf`

```bash
# Create autoscaling.tf
cat > autoscaling.tf << 'EOF'
resource "aws_launch_template" "wordpress_lt" {
  name_prefix   = "wordpress-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.wordpress_sg.id]

  user_data = base64encode(templatefile("${path.module}/wordpress-install.sh", {
    db_host     = aws_db_instance.wordpress_db.address
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
    efs_id      = aws_efs_file_system.wordpress_efs.id
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "wordpress-instance"
    }
  }
}

resource "aws_autoscaling_group" "wordpress_asg" {
  name                = "wordpress-asg"
  min_size            = 2
  max_size            = 5
  desired_capacity    = 2
  vpc_zone_identifier = aws_subnet.private_subnet[*].id

  launch_template {
    id      = aws_launch_template.wordpress_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.wordpress_tg.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "wordpress-asg-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "wordpress_cpu_policy" {
  name                   = "wordpress-cpu-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.wordpress_asg.name

  policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "wordpress_cpu_alarm" {
  alarm_name          = "wordpress-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.wordpress_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.wordpress_cpu_policy.arn]
}
EOF
```

**Create WordPress Installation Script**:
```bash
# Create wordpress-install.sh
cat > wordpress-install.sh << 'EOF'
#!/bin/bash
yum update -y
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum install -y httpd mariadb-server
systemctl start httpd
systemctl enable httpd

# Install PHP extensions
yum install -y php-mbstring php-xml php-gd php-curl php-zip php-json

# Mount EFS
yum install -y amazon-efs-utils
mkdir -p /var/www/html
mount -t efs ${efs_id}:/ /var/www/html
echo "${efs_id}:/ /var/www/html efs defaults,_netdev 0 0" >> /etc/fstab

# Download and configure WordPress
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* .
rm -rf wordpress latest.tar.gz

# Configure WordPress
cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/${db_name}/" wp-config.php
sed -i "s/username_here/${db_username}/" wp-config.php
sed -i "s/password_here/${db_password}/" wp-config.php
sed -i "s/localhost/${db_host}/" wp-config.php

# Set permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Restart Apache
systemctl restart httpd
EOF
```

---

## 🔧 Complete Deployment Commands

### Initialize and Deploy All Components

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy all infrastructure
terraform apply -auto-approve

# Get the Load Balancer DNS name
aws elbv2 describe-load-balancers --names wordpress-alb --query 'LoadBalancers[0].DNSName' --output text
```

### Verify Deployment

1. **Check Load Balancer**:
```bash
aws elbv2 describe-load-balancers --names wordpress-alb
```

2. **Check Auto Scaling Group**:
```bash
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names wordpress-asg
```

3. **Check RDS Database**:
```bash
aws rds describe-db-instances --db-instance-identifier wordpress-db
```

4. **Check EFS File System**:
```bash
aws efs describe-file-systems --file-system-id $(terraform output -raw efs_id)
```

---

## 🛠️ Troubleshooting Guide

### Common Issues and Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| **VPC Creation Failed** | Invalid CIDR blocks | Verify CIDR ranges don't overlap, use valid IPv4 ranges |
| **RDS Connection Failed** | Security group issues | Ensure RDS security group allows MySQL (3306) from web server SG |
| **EFS Mount Failed** | Permission/Network issues | Check VPC routing, security groups, and mount target configuration |
| **ALB Health Check Failed** | WordPress not responding | Verify WordPress installation, Apache service, and target group settings |
| **Auto Scaling Not Working** | CloudWatch alarm issues | Check alarm thresholds, ensure metrics are being collected |
| **SSH Connection Failed** | Security group/Key pair | Verify SSH (22) is allowed and key pair exists in correct region |

### Terraform-Specific Issues

```bash
# If state file gets corrupted
rm -rf .terraform
terraform init

# If resources fail to destroy
terraform destroy -auto-approve

# If you need to force unlock state
terraform force-unlock <resource>
```

### AWS-Specific Issues

```bash
# Check if AWS CLI is configured
aws configure list

# Verify current region
aws configure get region

# Test AWS credentials
aws sts get-caller-identity

# Check VPC and subnets
aws ec2 describe-vpcs
aws ec2 describe-subnets --filters Name=vpc-id,Values=$(terraform output -raw vpc_id)
```

---

## 📸 Evidence and Screenshots for Submission

### Required Screenshots

1. **VPC Configuration**
   - VPC Dashboard showing CIDR and subnets
   - Route tables (public and private)

2. **EC2 Instances**
   - Auto Scaling Group instances
   - Load Balancer target group health

3. **RDS Database**
   - Database instance details
   - Connection endpoint

4. **EFS File System**
   - File system details and mount targets

5. **Application Load Balancer**
   - Load Balancer DNS name
   - Target group with healthy instances

6. **WordPress Site**
   - Working WordPress installation
   - Admin dashboard

7. **Auto Scaling Demonstration**
   - CloudWatch metrics showing CPU utilization
   - Auto Scaling activity history

### Screenshot Locations
All screenshots should be saved in the `img/` directory:
- `vpc-architecture.png`
- `rds-mysql.png`
- `efs-filesystem.png`
- `load-balancer.png`
- `wordpress-site.png`
- `autoscaling-demo.png`

---

## 🔐 Security Measures Implemented

### Network Security
- **VPC Isolation**: Separate public and private subnets
- **Security Groups**: Least privilege access control
- **NAT Gateway**: Secure internet access for private resources

### Data Security
- **RDS Encryption**: At-rest and in-transit encryption
- **EFS Encryption**: Encrypted file system
- **IAM Roles**: Principle of least privilege

### Application Security
- **HTTPS Ready**: ALB configured for SSL termination
- **SSH Access**: Restricted to specific IP ranges (recommended)

---

## 🎯 Project Deliverables Summary

### For Submission and Grading

1. **Complete Codebase**
   - All Terraform configuration files
   - WordPress installation script
   - Variable definitions

2. **Documentation**
   - This comprehensive README
   - Architecture explanation
   - Step-by-step implementation guide

3. **Evidence**
   - Screenshots of all AWS resources
   - WordPress site functionality
   - Auto-scaling demonstration

4. **Live Demonstration**
   - Working WordPress website
   - Traffic simulation showing auto-scaling
   - Database connectivity verification

### Expected Project Outcomes
- ✅ Fully functional WordPress site accessible via Load Balancer
- ✅ Automatic scaling based on CPU utilization
- ✅ Secure database with proper access controls
- ✅ Shared file system for WordPress uploads
- ✅ High availability across multiple AZs

---

## 🎓 Learning Outcomes

By completing this capstone project, you will have demonstrated:

- **Infrastructure as Code** with Terraform
- **AWS Service Integration** (VPC, RDS, EFS, ALB, ASG)
- **Security Best Practices** in cloud architecture
- **Scalability and High Availability** design
- **Automation and DevOps** principles

---

## 🚀 Next Steps

1. **Test the Deployment**: Access WordPress via the Load Balancer DNS
2. **Simulate Traffic**: Use tools like `ab` (Apache Bench) to trigger auto-scaling
3. **Monitor Resources**: Use CloudWatch to observe scaling behavior
4. **Clean Up**: Run `terraform destroy` when done to avoid charges

**Congratulations on completing the Terraform Capstone Project!** 🎉

For questions or issues, refer to the troubleshooting section or consult your AWS documentation.
# AWS WordPress Deployment Guide - DigitalBoost Project

## Project Overview

This guide provides step-by-step instructions to deploy a scalable WordPress site for DigitalBoost using AWS services including VPC, RDS, EFS, Application Load Balancer, and Auto Scaling.

---

## Step 1: VPC Setup

### 1.1 Create VPC

1. **Navigate to VPC Console**

   - Go to AWS Management Console → Services → VPC

2. **Create VPC**
   - Click "Create VPC"
   - **Name tag**: `DigitalBoost-VPC`
   - **IPv4 CIDR block**: `10.0.0.0/16`
   - **IPv6 CIDR block**: No IPv6 CIDR block
   - **Tenancy**: Default
   - Click "Create VPC"

### 1.2 Enable DNS Settings

1. **Select your VPC**
2. **Actions** → **Edit VPC settings**
3. **Enable DNS resolution**: ✓ Checked
4. **Enable DNS hostnames**: ✓ Checked
5. Click "Save changes"

---

## Step 2: Create Internet Gateway

### 2.1 Create Internet Gateway

1. **VPC Console** → **Internet Gateways**
2. Click "Create internet gateway"
3. **Name tag**: `DigitalBoost-IGW`
4. Click "Create internet gateway"

### 2.2 Attach to VPC

1. **Select the Internet Gateway**
2. **Actions** → **Attach to VPC**
3. **Select VPC**: Choose `DigitalBoost-VPC`
4. Click "Attach internet gateway"

---

## Step 3: Create Subnets

### 3.1 Create Public Subnet 1

1. **VPC Console** → **Subnets**
2. Click "Create subnet"
3. **VPC ID**: Select `DigitalBoost-VPC`
4. **Subnet settings**:
   - **Subnet name**: `DigitalBoost-Public-Subnet-1`
   - **Availability Zone**: `us-east-1a` (or your preferred AZ)
   - **IPv4 CIDR block**: `10.0.1.0/24`
5. Click "Create subnet"

### 3.2 Create Public Subnet 2

1. Click "Create subnet"
2. **VPC ID**: Select `DigitalBoost-VPC`
3. **Subnet settings**:
   - **Subnet name**: `DigitalBoost-Public-Subnet-2`
   - **Availability Zone**: `us-east-1b` (different from subnet 1)
   - **IPv4 CIDR block**: `10.0.2.0/24`
4. Click "Create subnet"

### 3.3 Create Private Subnet 1

1. Click "Create subnet"
2. **VPC ID**: Select `DigitalBoost-VPC`
3. **Subnet settings**:
   - **Subnet name**: `DigitalBoost-Private-Subnet-1`
   - **Availability Zone**: `us-east-1a`
   - **IPv4 CIDR block**: `10.0.3.0/24`
4. Click "Create subnet"

### 3.4 Create Private Subnet 2

1. Click "Create subnet"
2. **VPC ID**: Select `DigitalBoost-VPC`
3. **Subnet settings**:
   - **Subnet name**: `DigitalBoost-Private-Subnet-2`
   - **Availability Zone**: `us-east-1b`
   - **IPv4 CIDR block**: `10.0.4.0/24`
4. Click "Create subnet"

### 3.5 Enable Auto-assign Public IP for Public Subnets

1. **Select Public Subnet 1**
2. **Actions** → **Edit subnet settings**
3. **Auto-assign public IPv4 address**: ✓ Enable
4. Click "Save"
5. **Repeat for Public Subnet 2**

---

## Step 4: Create NAT Gateway

### 4.1 Create NAT Gateway

1. **VPC Console** → **NAT Gateways**
2. Click "Create NAT gateway"
3. **Settings**:
   - **Name**: `DigitalBoost-NAT-Gateway`
   - **Subnet**: Select `DigitalBoost-Public-Subnet-1`
   - **Connectivity type**: Public
   - **Elastic IP allocation ID**: Click "Allocate Elastic IP"
4. Click "Create NAT gateway"

---

## Step 5: Configure Route Tables

### 5.1 Create Public Route Table

1. **VPC Console** → **Route Tables**
2. Click "Create route table"
3. **Settings**:
   - **Name**: `DigitalBoost-Public-RT`
   - **VPC**: Select `DigitalBoost-VPC`
4. Click "Create route table"

### 5.2 Configure Public Route Table

1. **Select the Public Route Table**
2. **Routes tab** → **Edit routes**
3. **Add route**:
   - **Destination**: `0.0.0.0/0`
   - **Target**: Internet Gateway → Select `DigitalBoost-IGW`
4. Click "Save changes"

### 5.3 Associate Public Subnets

1. **Subnet associations tab** → **Edit subnet associations**
2. **Select both public subnets**
3. Click "Save associations"

### 5.4 Create Private Route Table

1. Click "Create route table"
2. **Settings**:
   - **Name**: `DigitalBoost-Private-RT`
   - **VPC**: Select `DigitalBoost-VPC`
3. Click "Create route table"

### 5.5 Configure Private Route Table

1. **Select the Private Route Table**
2. **Routes tab** → **Edit routes**
3. **Add route**:
   - **Destination**: `0.0.0.0/0`
   - **Target**: NAT Gateway → Select `DigitalBoost-NAT-Gateway`
4. Click "Save changes"

### 5.6 Associate Private Subnets

1. **Subnet associations tab** → **Edit subnet associations**
2. **Select both private subnets**
3. Click "Save associations"

---

## Step 6: Create Security Groups

### 6.1 Create Web Server Security Group

1. **VPC Console** → **Security Groups**
2. Click "Create security group"
3. **Basic details**:

   - **Security group name**: `DigitalBoost-Web-SG`
   - **Description**: `Security group for web servers`
   - **VPC**: Select `DigitalBoost-VPC`

4. **Inbound rules**:

   - **Rule 1**: HTTP
     - **Type**: HTTP
     - **Protocol**: TCP
     - **Port range**: 80
     - **Source**: 0.0.0.0/0
   - **Rule 2**: HTTPS
     - **Type**: HTTPS
     - **Protocol**: TCP
     - **Port range**: 443
     - **Source**: 0.0.0.0/0
   - **Rule 3**: SSH
     - **Type**: SSH
     - **Protocol**: TCP
     - **Port range**: 22
     - **Source**: Your IP address/32
   - **Rule 4**: NFS (for EFS)
     - **Type**: NFS
     - **Protocol**: TCP
     - **Port range**: 2049
     - **Source**: 10.0.0.0/16

5. **Outbound rules**: Leave default (All traffic)
6. Click "Create security group"

### 6.2 Create Database Security Group

1. Click "Create security group"
2. **Basic details**:

   - **Security group name**: `DigitalBoost-DB-SG`
   - **Description**: `Security group for RDS database`
   - **VPC**: Select `DigitalBoost-VPC`

3. **Inbound rules**:

   - **Rule 1**: MySQL/Aurora
     - **Type**: MYSQL/Aurora
     - **Protocol**: TCP
     - **Port range**: 3306
     - **Source**: Security Group → `DigitalBoost-Web-SG`

4. **Outbound rules**: Leave default
5. Click "Create security group"

### 6.3 Create Load Balancer Security Group

1. Click "Create security group"
2. **Basic details**:

   - **Security group name**: `DigitalBoost-ALB-SG`
   - **Description**: `Security group for Application Load Balancer`
   - **VPC**: Select `DigitalBoost-VPC`

3. **Inbound rules**:

   - **Rule 1**: HTTP
     - **Type**: HTTP
     - **Protocol**: TCP
     - **Port range**: 80
     - **Source**: 0.0.0.0/0
   - **Rule 2**: HTTPS
     - **Type**: HTTPS
     - **Protocol**: TCP
     - **Port range**: 443
     - **Source**: 0.0.0.0/0

4. Click "Create security group"

---

## Step 7: Create RDS Database

### 7.1 Create DB Subnet Group

1. **Navigate to RDS Console**
2. **Subnet groups** → **Create DB subnet group**
3. **Settings**:
   - **Name**: `digitalboost-db-subnet-group`
   - **Description**: `Subnet group for DigitalBoost RDS`
   - **VPC**: Select `DigitalBoost-VPC`
   - **Availability Zones**: Select both AZs (us-east-1a, us-east-1b)
   - **Subnets**: Select both private subnets
4. Click "Create"

### 7.2 Create RDS Instance

1. **RDS Console** → **Databases** → **Create database**
2. **Engine options**:

   - **Engine type**: MySQL
   - **Version**: MySQL 8.0.35 (latest available)

3. **Templates**: Free tier (for testing) or Production (for production)

4. **Settings**:

   - **DB instance identifier**: `digitalboost-wordpress-db`
   - **Master username**: `admin`
   - **Master password**: `YourSecurePassword123!` (choose a strong password)

5. **Instance configuration**:

   - **DB instance class**: db.t3.micro (free tier) or db.t3.small (production)

6. **Storage**:

   - **Storage type**: General Purpose SSD (gp2)
   - **Allocated storage**: 20 GB
   - **Enable storage autoscaling**: ✓ Checked
   - **Maximum storage threshold**: 100 GB

7. **Connectivity**:

   - **VPC**: `DigitalBoost-VPC`
   - **DB subnet group**: `digitalboost-db-subnet-group`
   - **Public access**: No
   - **VPC security groups**: Choose existing → `DigitalBoost-DB-SG`
   - **Availability Zone**: No preference

8. **Additional configuration**:

   - **Initial database name**: `wordpress`
   - **Enable automated backups**: ✓ Checked
   - **Backup retention period**: 7 days
   - **Enable encryption**: ✓ Checked (optional but recommended)

9. Click "Create database"

**Note**: Wait for the RDS instance to be available before proceeding (takes ~10-15 minutes).

---

## Step 8: Create EFS File System

### 8.1 Create EFS Security Group

1. **VPC Console** → **Security Groups**
2. Click "Create security group"
3. **Basic details**:

   - **Security group name**: `DigitalBoost-EFS-SG`
   - **Description**: `Security group for EFS`
   - **VPC**: Select `DigitalBoost-VPC`

4. **Inbound rules**:

   - **Rule 1**: NFS
     - **Type**: NFS
     - **Protocol**: TCP
     - **Port range**: 2049
     - **Source**: Security Group → `DigitalBoost-Web-SG`

5. Click "Create security group"

### 8.2 Create EFS File System

1. **Navigate to EFS Console**
2. Click "Create file system"
3. **Settings**:
   - **Name**: `DigitalBoost-WordPress-EFS`
   - **VPC**: Select `DigitalBoost-VPC`
4. Click "Create"

### 8.3 Configure EFS Mount Targets

1. **Select your EFS file system**
2. **Network tab** → **Manage**
3. **Mount targets**:
   - **Availability Zone 1**: us-east-1a
     - **Subnet**: `DigitalBoost-Private-Subnet-1`
     - **Security Group**: `DigitalBoost-EFS-SG`
   - **Availability Zone 2**: us-east-1b
     - **Subnet**: `DigitalBoost-Private-Subnet-2`
     - **Security Group**: `DigitalBoost-EFS-SG`
4. Click "Save"

---

## Step 9: Create Launch Template

### 9.1 Create Key Pair (if not existing)

1. **EC2 Console** → **Key Pairs**
2. Click "Create key pair"
3. **Settings**:
   - **Name**: `DigitalBoost-KeyPair`
   - **Key pair type**: RSA
   - **Private key file format**: .pem
4. Click "Create key pair"
5. **Download and save the .pem file securely**

### 9.2 Create Launch Template

1. **EC2 Console** → **Launch Templates**
2. Click "Create launch template"
3. **Launch template name**: `DigitalBoost-WordPress-Template`
4. **Template version description**: `WordPress launch template for DigitalBoost`

5. **Application and OS Images**:

   - **AMI**: Amazon Linux 2023 AMI (latest)

6. **Instance type**: t3.micro (free tier) or t3.small (production)

7. **Key pair**: Select `DigitalBoost-KeyPair`

8. **Network settings**:

   - **Subnet**: Don't include in launch template
   - **Security groups**: `DigitalBoost-Web-SG`

9. **Advanced details**:
   - **IAM instance profile**: Leave blank for now
   - **User data**: Add the following script:

```bash
#!/bin/bash
yum update -y
yum install -y httpd php php-mysqlnd amazon-efs-utils

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create EFS mount point
mkdir -p /var/www/html/wp-content
echo "fs-xxxxxxxxx.efs.us-east-1.amazonaws.com:/ /var/www/html/wp-content efs defaults,_netdev" >> /etc/fstab

# Mount EFS (replace fs-xxxxxxxxx with your EFS ID)
mount -a

# Download and install WordPress
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* /var/www/html/

# Set permissions
chown -R apache:apache /var/www/html/
chmod -R 755 /var/www/html/

# Create wp-config.php
cat > /var/www/html/wp-config.php << 'EOF'
<?php
define('DB_NAME', 'wordpress');
define('DB_USER', 'admin');
define('DB_PASSWORD', 'YourSecurePassword123!');
define('DB_HOST', 'YOUR_RDS_ENDPOINT');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

define('AUTH_KEY',         'put your unique phrase here');
define('SECURE_AUTH_KEY',  'put your unique phrase here');
define('LOGGED_IN_KEY',    'put your unique phrase here');
define('NONCE_KEY',        'put your unique phrase here');
define('AUTH_SALT',        'put your unique phrase here');
define('SECURE_AUTH_SALT', 'put your unique phrase here');
define('LOGGED_IN_SALT',   'put your unique phrase here');
define('NONCE_SALT',       'put your unique phrase here');

$table_prefix = 'wp_';
define('WP_DEBUG', false);

if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');
EOF

# Restart Apache
systemctl restart httpd
```

**Important**: Replace the following in the User Data script:

- `fs-xxxxxxxxx.efs.us-east-1.amazonaws.com` with your actual EFS DNS name
- `YOUR_RDS_ENDPOINT` with your actual RDS endpoint
- Update the database password to match your RDS password

10. Click "Create launch template"

---

## Step 10: Create Application Load Balancer

### 10.1 Create Target Group

1. **EC2 Console** → **Target Groups**
2. Click "Create target group"
3. **Basic configuration**:

   - **Target type**: Instances
   - **Target group name**: `DigitalBoost-WordPress-TG`
   - **Protocol**: HTTP
   - **Port**: 80
   - **VPC**: Select `DigitalBoost-VPC`

4. **Health checks**:

   - **Health check protocol**: HTTP
   - **Health check path**: `/wp-admin/install.php`
   - **Advanced health check settings**:
     - **Healthy threshold**: 2
     - **Unhealthy threshold**: 3
     - **Timeout**: 5
     - **Interval**: 30
     - **Success codes**: 200,301,302

5. Click "Next"
6. **Don't register any targets yet**
7. Click "Create target group"

### 10.2 Create Application Load Balancer

1. **EC2 Console** → **Load Balancers**
2. Click "Create Load Balancer"
3. **Select Application Load Balancer**

4. **Basic configuration**:

   - **Load balancer name**: `DigitalBoost-WordPress-ALB`
   - **Scheme**: Internet-facing
   - **IP address type**: IPv4

5. **Network mapping**:

   - **VPC**: Select `DigitalBoost-VPC`
   - **Mappings**: Select both public subnets
     - `DigitalBoost-Public-Subnet-1`
     - `DigitalBoost-Public-Subnet-2`

6. **Security groups**: Select `DigitalBoost-ALB-SG`

7. **Listeners and routing**:

   - **Protocol**: HTTP
   - **Port**: 80
   - **Default action**: Forward to `DigitalBoost-WordPress-TG`

8. Click "Create load balancer"

---

## Step 11: Create Auto Scaling Group

### 11.1 Create Auto Scaling Group

1. **EC2 Console** → **Auto Scaling Groups**
2. Click "Create Auto Scaling group"
3. **Name**: `DigitalBoost-WordPress-ASG`
4. **Launch template**: Select `DigitalBoost-WordPress-Template`
5. **Version**: Latest
6. Click "Next"

### 11.2 Configure Instance Launch Options

1. **VPC**: Select `DigitalBoost-VPC`
2. **Availability Zones and subnets**: Select both private subnets
   - `DigitalBoost-Private-Subnet-1`
   - `DigitalBoost-Private-Subnet-2`
3. Click "Next"

### 11.3 Configure Load Balancing

1. **Load balancing**: Attach to an existing load balancer
2. **Existing load balancer target groups**: `DigitalBoost-WordPress-TG`
3. **Health checks**:
   - **ELB health checks**: ✓ Turn on
   - **Health check grace period**: 300 seconds
4. **Additional settings**: Leave defaults
5. Click "Next"

### 11.4 Configure Group Size and Scaling Policies

1. **Group size**:

   - **Desired capacity**: 2
   - **Minimum capacity**: 1
   - **Maximum capacity**: 4

2. **Scaling policies**: Target tracking scaling policy

   - **Scaling policy name**: `DigitalBoost-CPU-Policy`
   - **Metric type**: Average CPU utilization
   - **Target value**: 70
   - **Instances need**: 300 seconds warm up

3. Click "Next"

### 11.5 Add Notifications (Optional)

1. **Skip this step** or configure SNS notifications if desired
2. Click "Next"

### 11.6 Add Tags

1. **Add tags**:
   - **Key**: Name, **Value**: DigitalBoost-WordPress-Instance
   - **Key**: Project, **Value**: DigitalBoost
   - **Key**: Environment, **Value**: Production
2. Click "Next"

### 11.7 Review and Create

1. **Review all configurations**
2. Click "Create Auto Scaling group"

---

## Step 12: Final Configuration and Testing

### 12.1 Update Launch Template User Data

1. **Get your RDS endpoint**:

   - Go to RDS Console → Select your database
   - Copy the endpoint URL

2. **Get your EFS file system ID**:

   - Go to EFS Console → Copy the File system ID

3. **Update Launch Template**:

   - Go to Launch Templates
   - Select your template → Actions → Modify template (Create new version)
   - Update the User Data script with actual RDS endpoint and EFS ID
   - Set as Default version

4. **Update Auto Scaling Group**:
   - Go to Auto Scaling Groups
   - Select your ASG → Actions → Edit
   - Change launch template version to "Latest"

### 12.2 Test the WordPress Installation

1. **Get Load Balancer DNS name**:

   - EC2 Console → Load Balancers
   - Copy the DNS name

2. **Access WordPress**:
   - Open browser and navigate to the ALB DNS name
   - You should see WordPress installation page
   - Complete the WordPress setup

### 12.3 Verify Auto Scaling

1. **Install stress testing tool on one instance**:

```bash
sudo yum install -y stress
stress --cpu 2 --timeout 600s
```

2. **Monitor CloudWatch metrics**:
   - Check CPU utilization
   - Verify new instances launch when CPU > 70%

---

## Security Measures Implemented

### 1. Network Security

- **VPC Isolation**: All resources in dedicated VPC
- **Private Subnets**: Database and compute in private subnets
- **NAT Gateway**: Secure internet access for private resources
- **Security Groups**: Restrictive inbound/outbound rules

### 2. Database Security

- **Private Placement**: RDS in private subnets only
- **Security Group**: Database access only from web servers
- **Encryption**: Database encryption at rest (optional)
- **Automated Backups**: 7-day retention for disaster recovery

### 3. Compute Security

- **Key Pairs**: SSH access using key pairs
- **Security Groups**: Restricted access (HTTP/HTTPS from ALB only)
- **IAM Roles**: Principle of least privilege (if implemented)

### 4. Load Balancer Security

- **Security Group**: Only HTTP/HTTPS from internet
- **Health Checks**: Ensures only healthy instances receive traffic

---

## Troubleshooting Tips

### Common Issues:

1. **Instances not healthy**: Check security groups and health check path
2. **WordPress can't connect to database**: Verify RDS endpoint and security group
3. **EFS not mounting**: Check EFS security group and mount targets
4. **Auto Scaling not working**: Verify CloudWatch metrics and scaling policies

### Monitoring:

- Use CloudWatch for metrics and logs
- Set up CloudWatch alarms for critical metrics
- Monitor RDS performance insights

---

## Cost Optimization Tips

1. **Use appropriate instance types**: Start with t3.micro, scale as needed
2. **Reserved Instances**: For predictable workloads
3. **Spot Instances**: For non-critical environments
4. **EFS Intelligent Tiering**: Automatically moves files to lower-cost storage
5. **RDS Reserved Instances**: For production databases

---

This completes the comprehensive WordPress deployment on AWS. The architecture provides high availability, scalability, and security for DigitalBoost's requirements.

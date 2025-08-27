# Comprehensive AWS WordPress Deployment Guide - DigitalBoost Project

## Understanding the Project Architecture

Before we begin building, it's crucial to understand what we're creating and why each component is necessary. Think of this WordPress deployment like building a secure office building with multiple floors, security systems, and backup power.

**The Big Picture:** We're creating a highly available, scalable WordPress website that can handle traffic spikes while maintaining security and performance. Our architecture separates concerns - the database lives in a secure private area, web servers can scale automatically based on demand, and everything is protected by multiple layers of security.

![Architecture Diagram](img/architecture-diagram.png)

**Key Architectural Principles:**

- **High Availability**: Resources span multiple Availability Zones so if one fails, others continue working
- **Scalability**: The system automatically adds or removes servers based on traffic
- **Security**: Multiple layers of protection using private networks and security groups
- **Shared Storage**: All web servers access the same WordPress files through EFS
- **Managed Services**: Using AWS managed services (RDS, EFS, ALB) reduces operational overhead

---

## Step 1: Creating the Virtual Private Cloud (VPC) - Your Network Foundation

### Understanding VPCs

Think of a VPC as your own private section of the AWS cloud - like having your own floor in a large office building. Everything you build will exist within this private network space, isolated from other AWS customers and the public internet (unless you specifically allow access).

The IP address range we choose (10.0.0.0/16) gives us 65,536 possible IP addresses to work with. This is like having 65,536 possible addresses on your private street. The "/16" tells us that the first 16 bits of the IP address are fixed (the "network" part), and the remaining 16 bits can vary (the "host" part).

### 1.1 Create Your VPC

Navigate to the AWS Management Console and search for "VPC" in the services menu. The VPC service is where we manage all our networking components.

Click "Create VPC" and you'll see several options. We're using "VPC only" because we want to build each component step by step to understand how they work together.

**Configuration Details:**

- **Name tag**: `DigitalBoost-VPC` - This is just a friendly name to help you identify this VPC later
- **IPv4 CIDR block**: `10.0.0.0/16` - This defines your private IP address space. We're using the 10.x.x.x range because it's designated for private networks and won't conflict with public internet addresses
- **IPv6 CIDR block**: Leave as "No IPv6 CIDR block" - IPv6 is not necessary for this project
- **Tenancy**: Default - This means your resources share physical hardware with other AWS customers (which is normal and secure)

Click "Create VPC" and AWS will provision your private network space.

![VPC Creation](img/vpc-creation.png)

### 1.2 Enable DNS Settings - Making Names Work

By default, your VPC doesn't automatically create DNS names for resources. Think of DNS like a phone book - it translates friendly names (like "my-database.amazon.com") into IP addresses that computers can use.

Select your newly created VPC and click "Actions" → "Edit VPC settings." You'll see two important options:

**Enable DNS resolution**: This allows resources in your VPC to resolve DNS names to IP addresses. Without this, your WordPress servers couldn't find your database using its DNS name.

**Enable DNS hostnames**: This automatically assigns DNS names to your EC2 instances, making them easier to identify and connect to.

Check both boxes and save changes. These settings are essential for your WordPress application to communicate with the database using AWS-provided DNS names rather than having to hard-code IP addresses.

---

## Step 2: Creating the Internet Gateway - Your Connection to the World

### Understanding Internet Gateways

An Internet Gateway is like the main entrance to your office building - it's the single point where traffic can enter or leave your VPC to reach the public internet. Without an Internet Gateway, your VPC would be completely isolated from the internet.

Think of it as a two-way door: it allows resources in your public subnets to reach the internet (for software updates, downloading WordPress, etc.) and allows internet users to reach your load balancer to access your website.

### 2.1 Create the Internet Gateway

In the VPC console, navigate to "Internet Gateways" and click "Create internet gateway."

**Configuration:**

- **Name tag**: `DigitalBoost-IGW` - Again, this is a friendly identifier

The Internet Gateway exists independently of your VPC initially - think of it as installing a door frame before connecting it to a building.

### 2.2 Attach the Gateway to Your VPC

After creation, you must explicitly attach the Internet Gateway to your VPC. Select your Internet Gateway and click "Actions" → "Attach to VPC."

Choose your `DigitalBoost-VPC` from the dropdown. This connection is like installing the door in the door frame - now traffic can flow between your VPC and the internet, but only for resources you specifically configure to use it.

![Attach IGW](img/attach-igw.png)

**Why This Two-Step Process?** AWS separates creation and attachment for flexibility. You might create an Internet Gateway for future use, or you might want to temporarily detach it for maintenance without deleting it entirely.

---

## Step 3: Creating Subnets - Organizing Your Network Space

### Understanding Subnets and Availability Zones

Subnets are like individual floors or departments within your office building (VPC). Each subnet exists in exactly one Availability Zone, which you can think of as separate buildings in different parts of the city. By spreading your resources across multiple Availability Zones, you ensure that if one "building" has problems (power outage, network issues, etc.), your other resources in different "buildings" keep working.

We're creating four subnets:

- **Two Public Subnets**: These are like reception areas where visitors (internet traffic) can enter
- **Two Private Subnets**: These are like secure back offices where sensitive work (database operations) happens

### 3.1 Create Public Subnet 1

Navigate to "Subnets" in the VPC console and click "Create subnet."

**Configuration Explained:**

- **VPC ID**: Select `DigitalBoost-VPC` - This tells AWS which "building" this subnet belongs to
- **Subnet name**: `DigitalBoost-Public-Subnet-1` - A descriptive name indicating this is a public subnet
- **Availability Zone**: Choose `us-east-1a` (or your region's equivalent) - This is like choosing which city district your subnet is located in
- **IPv4 CIDR block**: `10.0.1.0/24` - This gives this subnet 256 possible IP addresses (10.0.1.0 through 10.0.1.255)

**Understanding CIDR Notation**: The "/24" means the first 24 bits are fixed (10.0.1), leaving 8 bits for individual addresses. This gives us 2^8 = 256 addresses, though AWS reserves the first 4 and last 1 for system use, leaving 251 usable addresses.

### 3.2 Create Public Subnet 2

Follow the same process, but with these changes:

- **Subnet name**: `DigitalBoost-Public-Subnet-2`
- **Availability Zone**: Choose `us-east-1b` (different from the first subnet)
- **IPv4 CIDR block**: `10.0.2.0/24`

**Why Two Public Subnets?** Application Load Balancers require at least two subnets in different Availability Zones for high availability. If one AZ has problems, traffic can still flow through the other AZ.

### 3.3 and 3.4 Create Private Subnets

Create two more subnets with these specifications:

**Private Subnet 1:**

- **Subnet name**: `DigitalBoost-Private-Subnet-1`
- **Availability Zone**: `us-east-1a` (same as Public Subnet 1)
- **IPv4 CIDR block**: `10.0.3.0/24`

**Private Subnet 2:**

- **Subnet name**: `DigitalBoost-Private-Subnet-2`
- **Availability Zone**: `us-east-1b` (same as Public Subnet 2)
- **IPv4 CIDR block**: `10.0.4.0/24`

![Subnet List](img/subnet-list.png)

**Why Same AZs as Public Subnets?** This creates a paired architecture where each AZ has both public and private subnets. Resources in private subnets can communicate with resources in public subnets within the same AZ very efficiently.

### 3.5 Enable Auto-assign Public IP for Public Subnets

By default, instances launched in subnets don't get public IP addresses. For public subnets, we want instances to automatically receive public IPs so they can communicate with the internet.

For each public subnet:

1. Select the subnet
2. Click "Actions" → "Edit subnet settings"
3. Check "Auto-assign public IPv4 address"
4. Save changes

**What This Means**: Any EC2 instance launched in these public subnets will automatically get a public IP address, making it accessible from the internet (subject to security group rules).

---

## Step 4: Creating the NAT Gateway - Secure Internet Access for Private Resources

### Understanding NAT Gateways

A NAT (Network Address Translation) Gateway is like a secure courier service for your private subnets. Resources in private subnets can't directly access the internet because they don't have public IP addresses. The NAT Gateway sits in a public subnet and acts as an intermediary - it receives requests from private resources, makes those requests to the internet using its own public IP, then returns the responses.

Think of it like a company mail room: employees (private resources) can send mail out and receive responses, but outsiders can't directly contact individual employees - all communication goes through the mail room (NAT Gateway).

### 4.1 Create the NAT Gateway

Navigate to "NAT Gateways" in the VPC console and click "Create NAT gateway."

**Configuration Details:**

- **Name**: `DigitalBoost-NAT-Gateway`
- **Subnet**: Select `DigitalBoost-Public-Subnet-1` - The NAT Gateway must be in a public subnet to have internet access
- **Connectivity type**: Public - This NAT Gateway will route traffic to the public internet
- **Elastic IP allocation ID**: Click "Allocate Elastic IP" - This gives the NAT Gateway a static public IP address

**Why an Elastic IP?** The NAT Gateway needs a consistent public IP address. If you used a regular public IP, it might change when AWS performs maintenance, breaking your private resources' internet connectivity.

**Important Cost Note**: NAT Gateways have hourly charges plus data processing charges. They're running 24/7 once created, so this is one of the ongoing costs in your architecture.

---

## Step 5: Configuring Route Tables - Directing Network Traffic

### Understanding Route Tables

Route tables are like GPS systems for network traffic - they tell data packets where to go based on their destination. Every subnet must be associated with a route table that defines how traffic leaves that subnet.

Think of route tables as having rules like: "If someone wants to go to the grocery store (local traffic), take Main Street (stay in VPC). If someone wants to go to another city (internet traffic), take the highway on-ramp (Internet Gateway or NAT Gateway)."

### 5.1 Create Public Route Table

Navigate to "Route Tables" in the VPC console. You'll notice AWS already created a "Main" route table for your VPC, but it's better practice to create dedicated route tables for better organization and security.

Click "Create route table" with these settings:

- **Name**: `DigitalBoost-Public-RT`
- **VPC**: Select `DigitalBoost-VPC`

### 5.2 Configure Public Route Table Rules

Select your new public route table and click on the "Routes" tab. You'll see one route already exists - this is the "local" route that allows resources within your VPC to communicate with each other.

Click "Edit routes" and "Add route":

- **Destination**: `0.0.0.0/0` - This is a "default route" meaning "any destination not already specified"
- **Target**: Internet Gateway → Select `DigitalBoost-IGW`

![Public Route Table](img/public-route-table.png)

**What This Rule Means**: "For any traffic that isn't going to a local VPC address (10.0.0.0/16), send it through the Internet Gateway." This allows resources in public subnets to reach the internet and be reached from the internet.

### 5.3 Associate Public Subnets

Click the "Subnet associations" tab and then "Edit subnet associations." Select both of your public subnets and save.

**Why This Association Matters**: Until you associate subnets with this route table, they're still using the main route table, which doesn't have internet access configured.

### 5.4 Create and Configure Private Route Table

Create another route table:

- **Name**: `DigitalBoost-Private-RT`
- **VPC**: Select `DigitalBoost-VPC`

For the private route table, add this route:

- **Destination**: `0.0.0.0/0`
- **Target**: NAT Gateway → Select `DigitalBoost-NAT-Gateway`

![Private Route Table](img/private-route-table.png)

**Critical Difference**: Private subnets route internet traffic through the NAT Gateway instead of directly through the Internet Gateway. This means:

- Private resources can initiate connections to the internet (for updates, API calls, etc.)
- The internet cannot initiate connections back to private resources
- All outbound traffic appears to come from the NAT Gateway's IP address

### 5.5 Associate Private Subnets

Associate both private subnets with the private route table.

**Verification Tip**: After completing route table configuration, your public subnets should show they're using the public route table, and private subnets should show they're using the private route table.

---

## Step 6: Creating Security Groups - Your Network Firewalls

### Understanding Security Groups

Security Groups are like sophisticated security guards that check every visitor's credentials before allowing access. Unlike traditional firewalls that operate at the network level, Security Groups operate at the instance level - each EC2 instance, RDS database, etc., can have different security group rules.

Security Groups are "stateful," meaning if you allow traffic in one direction, the return traffic is automatically allowed. For example, if you allow inbound HTTP requests, the HTTP responses are automatically allowed back out.

### 6.1 Create Web Server Security Group

This security group will control access to your WordPress web servers.

Navigate to "Security Groups" in the VPC console and click "Create security group."

**Basic Configuration:**

- **Security group name**: `DigitalBoost-Web-SG`
- **Description**: `Security group for web servers` - Good descriptions help you remember the purpose later
- **VPC**: Select `DigitalBoost-VPC`

**Inbound Rules Explained:**

**Rule 1 - HTTP (Port 80):**

- **Type**: HTTP
- **Source**: 0.0.0.0/0 (anywhere)
- **Purpose**: Allows web browsers to request web pages from your WordPress servers

**Rule 2 - HTTPS (Port 443):**

- **Type**: HTTPS
- **Source**: 0.0.0.0/0 (anywhere)
- **Purpose**: Allows secure web traffic. Even if you don't initially have SSL certificates, this prepares for future HTTPS implementation

**Rule 3 - NFS (Port 2049):**

- **Type**: NFS
- **Source**: 10.0.0.0/16 (your entire VPC)
- **Purpose**: Allows web servers to access the EFS shared file system where WordPress files are stored

![Web SG Inbound Rules](img/web-sg-inbound.png)

**Security Best Practice**: Notice we're not opening ports "just in case." Each port opening is intentional and serves a specific purpose.

### 6.2 Create Database Security Group

This security group protects your RDS MySQL database.

**Configuration:**

- **Security group name**: `DigitalBoost-DB-SG`
- **Description**: `Security group for RDS database`

**Inbound Rule:**

- **Type**: MYSQL/Aurora (Port 3306)
- **Source**: Security Group → `DigitalBoost-Web-SG`

**Why Reference Another Security Group?** Instead of specifying IP addresses, we're saying "allow connections from any resource that has the Web Security Group attached." This is more flexible because:

- If web servers scale up/down, access is automatically granted/revoked
- IP addresses might change, but security group membership is consistent
- It clearly documents the intended communication pattern

### 6.3 Create Load Balancer Security Group

The Application Load Balancer needs its own security group because it has different access requirements than individual web servers.

**Configuration:**

- **Security group name**: `DigitalBoost-ALB-SG`
- **Description**: `Security group for Application Load Balancer`

**Inbound Rules:**

- **HTTP and HTTPS from 0.0.0.0/0**: The load balancer is the public entry point, so it must accept connections from anywhere on the internet

**Architectural Note**: The load balancer will forward traffic to web servers, but the web servers' security group will be updated later to only accept traffic from the load balancer, not directly from the internet.

---

## Step 7: Creating the RDS Database - Your Data Foundation

### Understanding Amazon RDS

Amazon RDS (Relational Database Service) is a managed database service that handles the complex operational tasks of running a database - backups, patching, monitoring, scaling, etc. Think of it like hiring a professional database administrator who works 24/7 and never takes sick days.

For WordPress, we need a MySQL database to store posts, pages, user accounts, comments, and configuration settings. Rather than installing and managing MySQL ourselves on EC2 instances, RDS provides a more reliable, secure, and maintainable solution.

### 7.1 Create Database Subnet Group

Before creating the RDS instance, we need to define which subnets it can use. AWS requires database subnet groups to span at least two Availability Zones for high availability.

Navigate to the RDS console and go to "Subnet groups."

**Configuration:**

- **Name**: `digitalboost-db-subnet-group`
- **Description**: `Subnet group for DigitalBoost RDS`
- **VPC**: Select `DigitalBoost-VPC`
- **Availability Zones**: Select both AZs you've been using
- **Subnets**: Select both private subnets

**Why Private Subnets Only?** Databases contain sensitive information and should never be directly accessible from the internet. By placing RDS in private subnets, we ensure it can only be accessed by resources within our VPC (specifically, our web servers).

### 7.2 Create the RDS MySQL Instance

Navigate to "Databases" in the RDS console and click "Create database."

**Engine Selection:**

- **Engine type**: MySQL
- **Version**: MySQL 8.0.35 (or latest available)

**Why MySQL?** WordPress was originally built for MySQL and has the best compatibility and performance with this database engine.

**Template Selection:**
Choose based on your needs:

- **Free tier**: For learning and testing (limited resources but no cost)
- **Production**: For actual client websites (more resources and features)

**Settings Configuration:**

- **DB instance identifier**: `digitalboost-wordpress-db` - This is the unique name for your database instance
- **Master username**: `admin` - This is the database administrator account
- **Master password**: Create a strong password and store it securely

**Instance Configuration:**

- **DB instance class**:
  - `db.t3.micro` for free tier/testing
  - `db.t3.small` or larger for production

**Understanding Instance Classes**: These determine CPU, memory, and network performance. Start small and scale up based on actual performance requirements.

**Storage Configuration:**

- **Storage type**: General Purpose SSD (gp2) - Good balance of price and performance
- **Allocated storage**: 20 GB minimum
- **Enable storage autoscaling**: Checked - Automatically increases storage when needed
- **Maximum storage threshold**: 100 GB - Prevents runaway storage costs

**Connectivity Settings:**

- **VPC**: `DigitalBoost-VPC`
- **DB subnet group**: `digitalboost-db-subnet-group`
- **Public access**: No - Critical security setting
- **VPC security groups**: Choose existing → `DigitalBoost-DB-SG`

**Additional Configuration:**

- **Initial database name**: `wordpress` - Creates a database ready for WordPress installation
- **Enable automated backups**: Checked - Essential for disaster recovery
- **Backup retention period**: 7 days - Balances safety with storage costs
- **Enable encryption**: Recommended for sensitive data

**Monitoring and Performance**: Leave default settings initially. You can enable Enhanced Monitoring later if you need detailed performance metrics.

Click "Create database" and wait approximately 10-15 minutes for the instance to become available. RDS is performing several complex setup tasks during this time.

![RDS Instance](img/rds-instance.png)

---

## Step 8: Setting Up EFS - Shared Storage for WordPress

### Understanding Elastic File System (EFS)

Traditional web servers store files locally on their hard drives. This works fine with a single server, but creates problems when you have multiple servers behind a load balancer - uploaded images might only exist on one server, themes might be different across servers, etc.

EFS solves this by providing a shared file system that all your web servers can mount simultaneously. Think of it like a shared network drive in an office - everyone can access the same files, and changes made by one person are immediately visible to everyone else.

### 8.1 Create EFS Security Group

EFS needs its own security group to control which resources can access the shared file system.

**Configuration:**

- **Security group name**: `DigitalBoost-EFS-SG`
- **Description**: `Security group for EFS`
- **VPC**: Select `DigitalBoost-VPC`

**Inbound Rule:**

- **Type**: NFS (Port 2049)
- **Source**: Security Group → `DigitalBoost-Web-SG`

**What This Rule Means**: Only resources with the web server security group can mount and access the EFS file system. This prevents unauthorized access to your WordPress files.

### 8.2 Create the EFS File System

Navigate to the EFS console and click "Create file system."

**Configuration:**

- **Name**: `DigitalBoost-WordPress-EFS`
- **VPC**: Select `DigitalBoost-VPC`

**Performance and Throughput**: Leave as default (General Purpose, Bursting) unless you expect very high file I/O requirements.

**Storage Classes**: EFS can automatically move infrequently accessed files to cheaper storage tiers, reducing costs over time.

### 8.3 Configure EFS Mount Targets

Mount targets are like access points that allow EC2 instances in specific subnets to connect to the EFS file system. You need one mount target per Availability Zone where you have resources that need EFS access.

Select your EFS file system and go to the "Network" tab, then click "Manage."

**Mount Target Configuration:**

- **Availability Zone 1**: us-east-1a
  - **Subnet**: `DigitalBoost-Private-Subnet-1`
  - **Security Group**: `DigitalBoost-EFS-SG`
- **Availability Zone 2**: us-east-1b
  - **Subnet**: `DigitalBoost-Private-Subnet-2`
  - **Security Group**: `DigitalBoost-EFS-SG`

![EFS Mount Targets](img/efs-mount-targets.png)

**Why Private Subnets?** While EFS could work in public subnets, placing mount targets in private subnets provides an additional security layer and follows the principle of keeping internal resources internal.

**DNS Names**: After creation, EFS provides DNS names for mounting. These follow the pattern: `fs-xxxxxxxxx.efs.region.amazonaws.com`

---

## Step 9: Creating the Launch Template - Defining Your Server Configuration

### Understanding Launch Templates

A Launch Template is like a blueprint or recipe for creating EC2 instances. It defines everything about how new instances should be configured - what operating system, what size, what security settings, and what software to install automatically.

This is crucial for auto-scaling because when traffic increases and new instances need to be launched automatically, the launch template ensures they're configured identically to existing instances.

### 9.1 Configure Secure Instance Access with IAM and AWS Systems Manager

For secure access to your instances for troubleshooting and management, we will use **AWS Systems Manager Session Manager**. This is the most secure, AWS-native approach and avoids the need for SSH keys or opening port 22 in your security groups. Your instances are intentionally placed in private subnets and should not be directly accessible from the internet; Session Manager provides access without compromising this security posture.

To enable Session Manager, you need to:
1.  Create an IAM role with the `AmazonSSMManagedInstanceCore` policy.
2.  Attach this IAM role to the instances via the Launch Template (covered in the next step).

This provides secure, auditable access directly from the AWS console.

**Alternative Access Method: Bastion Host**

Alternatively, for teams that prefer or require traditional SSH access, a bastion host (or jump box) can be set up. This involves launching a dedicated EC2 instance in a public subnet that is hardened and strictly monitored. Administrators would first SSH into the bastion host and then, from that host, connect to the private instances. This method is more complex to manage and secure than Session Manager and is therefore not the primary recommended approach.

### 9.2 Create the Launch Template

Navigate to "Launch Templates" in the EC2 console and click "Create launch template."

**Basic Configuration:**

- **Launch template name**: `DigitalBoost-WordPress-Template`
- **Template version description**: `WordPress launch template for DigitalBoost` - Good descriptions help track changes over time

**AMI Selection:**

- **Application and OS Images**: Amazon Linux 2023 AMI
- **Why Amazon Linux?** It's optimized for AWS, receives regular security updates, and includes many AWS tools pre-installed

**Instance Type:**

- **t3.micro** for free tier/testing
- **t3.small** for light production workloads
- **t3.medium** or larger for higher traffic sites

**IAM instance profile**: Attach the IAM role you created with `AmazonSSMManagedInstanceCore` permissions.

**Network Settings:**

- **Subnet**: Don't include in launch template - This allows the Auto Scaling Group to choose subnets dynamically
- **Security groups**: `DigitalBoost-Web-SG`

### 9.3 Understanding the User Data Script

User Data is a script that runs when an instance first boots. This script automatically installs and configures WordPress, eliminating manual setup for each new instance. The script is designed to be robust, idempotent (it can be run multiple times without causing issues), and secure.

For the full, up-to-date script, please see the `UserData_ALB_ASG.txt` file in this directory.

**The Script Explained Section by Section:**

This script is more advanced than a basic setup. It includes variables for easy configuration, a comprehensive set of software packages, dynamic security key generation, a dedicated health check endpoint, and proper permissions and ownership settings.

**Configuration and Customization**:

- **Variables**: At the top of the script, you can easily edit the database name, user, password, RDS host, and EFS DNS name.
  ```bash
  # --- Variables (EDIT THESE) ---
  DB_NAME="wordpress"
  DB_USER="admin"
  DB_PASSWORD="3aFZd1k4#!*ZISE5"     # <-- Replace with RDS password
  DB_HOST="database-1.cgdgaymio2yi.us-east-1.rds.amazonaws.com"        # <-- Replace with RDS endpoint
  EFS_DNS="fs-0a468f2fa2470a92d.efs.us-east-1.amazonaws.com"  # <-- Replace with your EFS DNS name
  ```
- **Software Installation**: The script installs Apache, PHP 8.0 with necessary extensions, and the MySQL client for connectivity testing.
- **EFS Mount**: It configures `/etc/fstab` to automatically mount the EFS drive to `/var/www/html`, ensuring persistent shared storage.
- **Idempotent WordPress Installation**: The script checks if WordPress is already installed before downloading it. This prevents accidental overwrites on instance reboots.
- **`wp-config.php` Automation**:
    - The script creates the `wp-config.php` file using the variables you defined.
    - **Crucially, it fetches fresh, unique security keys and salts from the official WordPress.org API every time it runs.** This is a major security enhancement.
    - It includes logic to ensure WordPress works correctly behind a load balancer, including forcing SSL for the admin dashboard and handling SSL termination.
  ```bash
  # --- Configure wp-config.php ---
  cat > /var/www/html/wp-config.php <<EOL
  <?php
  // WordPress Configuration File - DigitalBoost Project

  // Database settings
  define('DB_NAME', '${DB_NAME}');
  define('DB_USER', '${DB_USER}');
  define('DB_PASSWORD', '${DB_PASSWORD}');
  define('DB_HOST', '${DB_HOST}');
  define('DB_CHARSET', 'utf8');
  define('DB_COLLATE', '');

  // Security keys and salts (auto-generated)
  EOL

  # Fetch salts from WordPress API
  curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> /var/www/html/wp-config.php

  cat >> /var/www/html/wp-config.php <<'EOL'

  // Table prefix
  $table_prefix = 'wp_';

  // Debug mode
  define('WP_DEBUG', false);

  // Force WordPress to use Load Balancer domain
  define('WP_HOME', 'http://' . $_SERVER['HTTP_HOST']);
  define('WP_SITEURL', 'http://' . $_SERVER['HTTP_HOST']);

  define('FORCE_SSL_ADMIN', true);
  // SSL termination at ALB
  if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
      $_SERVER['HTTPS'] = 'on';
  }

  // File system method
  define('FS_METHOD', 'direct');

  // Absolute path
  if (!defined('ABSPATH')) {
      define('ABSPATH', dirname(__FILE__) . '/');
  }

  require_once(ABSPATH . 'wp-settings.php');
  EOL
  ```
- **Health Check**: It creates a lightweight `health.php` file. You should configure your load balancer's target group to use `/health.php` for health checks. This is more efficient than using the default WordPress pages.
  ```bash
  # --- Health check endpoint for ALB ---
  cat > /var/www/html/health.php <<'EOL'
  <?php
  http_response_code(200);
  echo "Server: " . gethostname() . " - Status: OK - Time: " . date('Y-m-d H:i:s');
  ?>
  EOL
  ```
- **Apache Configuration**: A dedicated `wordpress.conf` file is created for Apache, setting the document root and allowing `.htaccess` overrides for permalinks. It also sets common PHP values for better performance.
- **Logging**: The script creates a log file at `/var/log/wordpress-install.log` to help troubleshoot installation issues.

---

## Step 10: Creating the Application Load Balancer - Distributing Traffic Intelligently

### Understanding Application Load Balancers

An Application Load Balancer (ALB) is like a smart traffic director that sits between the internet and your web servers. Unlike a simple router, an ALB understands HTTP/HTTPS traffic and can make intelligent routing decisions based on the content of requests.

Key benefits include:

- **High Availability**: If one web server fails, traffic is automatically routed to healthy servers
- **SSL Termination**: The ALB can handle SSL certificates, reducing CPU load on web servers
- **Health Checks**: Continuously monitors server health and removes unhealthy servers from rotation
- **Scalability**: Can handle thousands of concurrent connections

### 10.1 Create Target Group First

Before creating the load balancer, we need to define where traffic should be sent. A Target Group is a collection of resources (EC2 instances) that receive traffic from the load balancer.

Navigate to EC2 console → "Target Groups" and click "Create target group."

**Configuration:**

- **Target type**: Instances - We're targeting EC2 instances specifically
- **Target group name**: `DigitalBoost-WordPress-TG`
- **Protocol**: HTTP, **Port**: 80 - Standard web traffic
- **VPC**: Select `DigitalBoost-VPC`

**Health Check Configuration:**
Health checks are critical for ensuring users only reach working servers.

- **Health check protocol**: HTTP
- **Health check path**: `/wp-admin/install.php` - This WordPress file indicates the server is properly serving content
- **Advanced settings**:
  - **Healthy threshold**: 2 consecutive successful checks mark instance as healthy
  - **Unhealthy threshold**: 3 consecutive failed checks mark instance as unhealthy
  - **Timeout**: 5 seconds to wait for response
  - **Interval**: 30 seconds between checks
  - **Success codes**: 200,301,302 - WordPress might redirect during setup, so we accept redirect status codes

**Why These Settings?** The health check path ensures not just that Apache is running, but that WordPress is properly configured and responding. The thresholds prevent instances from being marked unhealthy due to temporary network hiccups.

Don't register any targets yet - the Auto Scaling Group will handle that automatically.

### 10.2 Create the Application Load Balancer

Navigate to "Load Balancers" and click "Create Load Balancer," then select "Application Load Balancer."

**Basic Configuration:**

- **Load balancer name**: `DigitalBoost-WordPress-ALB`
- **Scheme**: Internet-facing - This allows the load balancer to receive traffic from the internet
- **IP address type**: IPv4 - Standard internet addressing

**Network Mapping:**

- **VPC**: Select `DigitalBoost-VPC`
- **Mappings**: Select both public subnets

**Why Both Public Subnets?** ALBs require at least two subnets in different Availability Zones for high availability. If one AZ becomes unavailable, the ALB continues operating from the other AZ.

**Security Groups**: Select `DigitalBoost-ALB-SG`

**Listeners and Routing:**
A listener is a process that checks for connection requests on a specific port and protocol.

- **Protocol**: HTTP, **Port**: 80
- **Default action**: Forward to `DigitalBoost-WordPress-TG`

![ALB Listener](img/alb-listener.png)

**What This Means**: Any HTTP request to the load balancer will be forwarded to instances in the target group. Later, you can add HTTPS listeners with SSL certificates.

**DNS Name**: After creation, AWS provides a DNS name like `DigitalBoost-WordPress-ALB-123456789.us-east-1.elb.amazonaws.com`. This is how users will access your website.

---

## Step 11: Creating the Auto Scaling Group - Automatic Capacity Management

### Understanding Auto Scaling Groups

An Auto Scaling Group (ASG) is like having an intelligent facilities manager who automatically hires more staff when the office gets busy and reduces staff when things are quiet. It continuously monitors your application's performance and adjusts the number of running instances based on demand.

This provides several benefits:

- **Cost Optimization**: Only pay for resources you actually need
- **High Availability**: If an instance fails, ASG automatically replaces it
- **Performance**: Scale up before users experience slowdowns
- **Operational Efficiency**: No need to manually monitor and adjust capacity

### 11.1 Create the Auto Scaling Group

Navigate to EC2 console → "Auto Scaling Groups" and click "Create Auto Scaling group."

**Basic Configuration:**

- **Name**: `DigitalBoost-WordPress-ASG`
- **Launch template**: Select `DigitalBoost-WordPress-Template`
- **Version**: Latest - This ensures new instances use the most recent template configuration

**Why Use Latest Version?** When you update your launch template (for security patches, configuration changes, etc.), setting the version to "Latest" means new instances will automatically use the updated configuration.

### 11.2 Configure Instance Launch Options

**VPC**: Select `DigitalBoost-VPC`

**Availability Zones and Subnets**: Select both private subnets

- `DigitalBoost-Private-Subnet-1`
- `DigitalBoost-Private-Subnet-2`

**Understanding the Private Subnet Strategy**: This might seem counterintuitive at first glance since web servers need to serve internet traffic, but there's a sophisticated architectural reason behind this decision. When we place web servers in private subnets, we create what's known as a "defense in depth" security model.

Think of this like a high-security office building. Visitors (internet users) can't directly access individual offices (web servers). Instead, they must go through the reception desk (load balancer) in the lobby (public subnet), and the receptionist directs them to the appropriate office worker. This means that even if someone discovers the internal office number (server IP address), they can't reach it directly from outside the building.

The beauty of this architecture is that web servers in private subnets can still receive traffic, but only through the load balancer. This prevents several types of attacks: direct IP scanning of your servers, bypassing your load balancer's security features, and distributed denial of service attacks against individual servers rather than your protected load balancer.

Meanwhile, your servers can still reach the internet when they need to (for software updates, API calls to external services, downloading WordPress plugins) through the NAT Gateway, but the internet cannot initiate connections back to them.

### 11.3 Configure Advanced Load Balancing Integration

**Load balancing**: Select "Attach to an existing load balancer"
**Existing load balancer target groups**: Choose `DigitalBoost-WordPress-TG`

**Understanding Target Group Integration**: When you attach your Auto Scaling Group to a target group, you're creating an automatic registration system. Think of it like a sophisticated employee badge system in our office building analogy. When new employees (EC2 instances) are hired (launched), they automatically receive badges (get registered with the target group) that allow the reception desk (load balancer) to direct visitors to them.

This integration means that as your Auto Scaling Group adds or removes instances based on demand, the load balancer automatically knows about these changes. New instances become available to receive traffic as soon as they pass their health checks, and terminated instances are immediately removed from rotation, ensuring users never get directed to non-existent servers.

**Health Check Configuration**:

- **ELB health checks**: Turn this on - This is a critical decision that transforms how your Auto Scaling Group determines instance health
- **Health check grace period**: 300 seconds (5 minutes)

**Why ELB Health Checks Are Superior**: By default, Auto Scaling Groups use basic EC2 health checks, which only verify that the virtual machine is running. This is like a building security system that only checks if the lights are on in an office, but doesn't verify if anyone is actually working there.

ELB (Elastic Load Balancer) health checks are much more sophisticated. They actually make HTTP requests to your WordPress application and verify that it responds correctly. This means the health check confirms not just that the server is running, but that Apache is working, PHP is functioning, WordPress is responding, and the database connection is healthy. If WordPress crashes but the EC2 instance continues running, ELB health checks will detect this and mark the instance as unhealthy, triggering a replacement.

**Understanding Grace Period**: New instances need time to complete their startup process. Your user data script must download and install software, configure WordPress, mount the EFS file system, and establish database connections. The grace period prevents the Auto Scaling Group from prematurely terminating instances that are still completing their initialization process. During this grace period, the ASG won't terminate instances even if they fail health checks, giving them time to become fully operational.

### 11.4 Configure Group Size and Scaling Policies - The Heart of Auto Scaling

This section configures the intelligence that makes your infrastructure responsive to demand changes. Think of this as programming a smart thermostat for your application's capacity needs.

**Group Size Configuration**:

- **Desired capacity**: 2 instances
- **Minimum capacity**: 1 instance
- **Maximum capacity**: 4 instances

**Understanding Capacity Settings**: These three numbers define the boundaries of your scaling behavior, and each serves a specific purpose in maintaining both availability and cost control.

The **minimum capacity** of 1 ensures your website never goes completely offline, even during the lowest traffic periods. This is your safety net - no matter what happens with scaling decisions, you'll always have at least one server running to handle requests.

The **desired capacity** of 2 provides operational resilience. With two instances running under normal conditions, you have immediate redundancy. If one instance fails, the other continues serving traffic while the Auto Scaling Group launches a replacement. This prevents any service interruption during instance failures and also distributes load across multiple servers, improving performance.

The **maximum capacity** of 4 acts as your cost protection mechanism. It prevents runaway scaling during unexpected events (like a sudden viral social media mention of your client's website) from generating enormous AWS bills. Four instances can typically handle significant traffic loads, but you can adjust this number based on your specific performance testing and budget constraints.

**Scaling Policy Configuration**:
Choose "Target tracking scaling policy" - this represents the most sophisticated and user-friendly scaling approach available.

**Policy Details**:

- **Scaling policy name**: `DigitalBoost-CPU-Policy`
- **Metric type**: Average CPU utilization
- **Target value**: 70 percent
- **Instances need**: 300 seconds warm up before including in metrics

![ASG Scaling Policy](img/asg-scaling-policy.png)

**How Target Tracking Scaling Works**: Unlike simple scaling policies that react to threshold breaches, target tracking continuously monitors your chosen metric and makes gradual adjustments to keep the metric near your target value. It's like cruise control for your infrastructure capacity.

When the average CPU utilization across all your instances rises above 70%, the system doesn't just add one instance and wait. Instead, it calculates how many instances are needed to bring the average back down to 70% and launches that number of instances. Conversely, when CPU usage drops below 70%, it gradually removes instances while ensuring it never goes below your minimum capacity.

**Why 70% CPU Target**: This percentage provides an optimal balance between performance and cost efficiency. At 70% CPU utilization, your servers are working efficiently but still have enough headroom to handle sudden spikes in traffic while new instances are launching (which typically takes 3-5 minutes). If you set the target too low (like 30%), you'd have many lightly-loaded instances, increasing costs unnecessarily. If you set it too high (like 90%), users might experience slow response times during traffic spikes before scaling can respond.

**Understanding Warm-up Period**: New instances need time to become fully operational and start handling their fair share of traffic. During the 300-second warm-up period, new instances don't contribute to the average CPU calculation for scaling decisions. This prevents a scaling cascade where new instances, still starting up and showing low CPU usage, cause the system to think more instances are needed.

### 11.5 Add Notifications - Staying Informed About Your Infrastructure

**Notification Configuration** (Optional but Recommended for Production):
While you can skip notifications during initial learning, they become essential for production environments where you need to monitor infrastructure changes and respond to issues quickly.

**SNS (Simple Notification Service) Integration**:
If you choose to configure notifications, you can create SNS topics that send emails or SMS messages when scaling events occur. This helps you understand your application's usage patterns and respond to potential issues.

Typical notifications include:

- Instance launch events (traffic is increasing)
- Instance termination events (traffic is decreasing)
- Failed scaling actions (requires investigation)
- Health check failures (may indicate application problems)

For this tutorial environment, you can skip notifications, but in a real client project, you'd want to configure at least email notifications to the operations team.

### 11.6 Add Tags - Organization and Cost Management

Tags serve multiple critical functions in AWS environments: organization, cost allocation, automation, and compliance tracking.

**Essential Tags for This Project**:

- **Name**: `DigitalBoost-WordPress-Instance` - This appears in the EC2 console, making it easy to identify which instances belong to this project
- **Project**: `DigitalBoost` - Enables cost reporting by project and helps with resource grouping
- **Environment**: `Production` (or `Development`/`Staging` as appropriate) - Critical for preventing accidental changes to production resources
- **Owner**: Your name or team identifier - Essential in shared AWS accounts for accountability
- **Application**: `WordPress` - Helps identify the application purpose
- **Backup**: `Required` - Can trigger automated backup policies

**Tag Propagation Settings**: Ensure you check "Tag new instances" so that all EC2 instances launched by the Auto Scaling Group automatically inherit these tags. This maintains consistent tagging as instances scale up and down.

**Why Tagging Matters**: In a few months, when you have multiple projects and dozens of resources, tags become essential for understanding what resources exist, who owns them, what they cost, and whether they can be safely modified or deleted. Good tagging practices established early prevent significant operational headaches later.

### 11.7 Review and Create - Final Validation

The review screen presents your complete Auto Scaling Group configuration. This is your final opportunity to verify that all settings align with your architectural goals.

**Critical Items to Double-Check**:

- Launch template is correct and uses the latest version
- Subnets are private subnets spanning multiple Availability Zones
- Load balancer target group attachment is configured
- Scaling policy thresholds make sense for your expected traffic patterns
- Minimum capacity ensures high availability
- Maximum capacity protects against runaway costs

Once you click "Create Auto Scaling group," several automated processes begin immediately. The ASG will start launching your desired capacity of 2 instances, using your launch template configuration. Each instance will run through the complete user data script, installing and configuring WordPress, mounting EFS storage, and connecting to your RDS database.

---

## Step 12: Final Configuration and Testing - Orchestrating All Components

### Understanding the Deployment Timeline

When your Auto Scaling Group launches, you're witnessing the orchestration of multiple complex systems working together. Here's what happens in the background during those first critical minutes:

**Minutes 1-2**: EC2 instances boot and begin executing user data scripts
**Minutes 2-5**: Software installation (Apache, PHP, WordPress) occurs
**Minutes 3-6**: EFS mounting and WordPress configuration happens
**Minutes 4-7**: Database connections are established and WordPress initializes
**Minutes 5-8**: Load balancer health checks begin passing
**Minutes 6-10**: Instances become available to receive production traffic

This timeline helps you understand why certain configuration values (like health check grace periods and scaling warm-up times) are set as they are.

### 12.1 Update Launch Template with Real Values - Critical Configuration Step

Your current launch template contains placeholder values that must be replaced with actual AWS resource identifiers. This step transforms your template from a generic configuration into one specifically tailored for your infrastructure.

**Retrieve Your RDS Endpoint**:
Navigate to the RDS Console and select your `digitalboost-wordpress-db` instance. In the "Connectivity & security" section, you'll find the endpoint URL. This will look something like: `digitalboost-wordpress-db.c1xyzabc123.us-east-1.rds.amazonaws.com`

**Understanding RDS Endpoints**: This endpoint is actually a DNS name that AWS manages for you. Behind this single DNS name, AWS can perform database failovers, maintenance, and scaling operations without requiring you to update your application configuration. Your WordPress instances will always connect to this endpoint, and AWS ensures it always points to the active database server.

**Retrieve Your EFS File System Information**:
Navigate to the EFS Console and select your `DigitalBoost-WordPress-EFS` file system. You need two pieces of information:

1. The File system ID (starts with `fs-`)
2. The regional DNS name (which follows the pattern `fs-xxxxxxxxx.efs.region.amazonaws.com`)

**Understanding EFS Endpoints**: Like RDS, EFS provides regional DNS names that automatically resolve to the optimal mount target based on which Availability Zone your instance is running in. This ensures the best possible network performance and automatic failover if one AZ becomes unavailable.

**Update Process**:

1. Navigate to EC2 Console → Launch Templates
2. Select `DigitalBoost-WordPress-Template`
3. Choose "Actions" → "Modify template (Create new version)"
4. Scroll to "Advanced details" and locate the User data field
5. Replace all placeholder values with your actual resource identifiers:

   - Replace the EFS DNS name in the fstab entry
   - Replace the RDS endpoint in the wp-config.php configuration
   - Update the database password to match your RDS master password
   - Consider generating unique WordPress security keys from https://api.wordpress.org/secret-key/1.1/salt/

6. Create the new template version
7. Set this new version as the "Default version"

**Update Auto Scaling Group Configuration**:
Your existing instances were launched with the placeholder template, so you need to configure the ASG to use the updated template for any future scaling activities:

1. Navigate to Auto Scaling Groups
2. Select `DigitalBoost-WordPress-ASG`
3. Click "Edit"
4. Change the launch template version from "1" to "Latest"
5. Save changes

### 12.2 Perform Instance Refresh - Ensuring Consistency

Your currently running instances still use the old template with placeholder values. To ensure all instances use the correct configuration, you should perform an instance refresh. This process gradually replaces old instances with new ones using the updated template.

**Instance Refresh Process**:

1. In your Auto Scaling Group console, select "Instance refresh"
2. Choose "Rolling replacement" as the replacement strategy
3. Set minimum healthy percentage to 50% (ensures at least one instance remains running during refresh)
4. The process will terminate old instances one at a time and launch replacements

**Why Instance Refresh Matters**: This ensures that all your running instances have the correct database connections and EFS mounts. Without this step, you might have some instances that can't connect to your database or shared file system, leading to inconsistent behavior.

**Monitoring the Refresh**: The refresh process typically takes 10-15 minutes. You can monitor progress in the ASG console and watch new instances appear in the EC2 console. The load balancer health checks ensure that old instances don't stop receiving traffic until new instances are fully ready.

### 12.3 Verify WordPress Installation - Testing Your Architecture

**Obtain Your Application URL**:
Navigate to EC2 Console → Load Balancers and select `DigitalBoost-WordPress-ALB`. Copy the DNS name from the description tab. This URL represents the single point of entry for your entire WordPress infrastructure.

**Initial WordPress Setup**:
Open your browser and navigate to your load balancer DNS name. If everything is configured correctly, you should see the WordPress installation wizard. This seemingly simple page load actually demonstrates that multiple complex systems are working together:

1. Your browser connects to the load balancer's public IP
2. The load balancer forwards your request to a healthy web server in a private subnet
3. The web server processes the PHP request, accessing files from EFS
4. WordPress connects to the RDS database to check installation status
5. The response travels back through the load balancer to your browser

![WordPress Installation](img/wordpress-install.png)

**Complete WordPress Setup**:
Follow the WordPress installation wizard:

- Select your preferred language
- The database connection should work automatically (using your wp-config.php settings)
- Create an administrator account with a strong password
- Set your site title and description
- Complete the installation

**Understanding What Just Happened**: When you completed the WordPress installation, the setup data was written to your RDS database and is now available to all web servers. Because all servers mount the same EFS file system, any themes, plugins, or uploaded media files are immediately available across all instances.

### 12.4 Test High Availability - Validating Resilience

**Verify Load Distribution**:
To confirm that your load balancer is distributing traffic across multiple instances, you can create a simple test page that displays the server hostname:

1. SSH into one of your instances (using your key pair and a public IP if available, or through AWS Systems Manager Session Manager)
2. Create a test file: `sudo nano /var/www/html/server-info.php`
3. Add this content:

```php
<?php
echo "<h1>Server Information</h1>";
echo "<p>Server Hostname: " . gethostname() . "</p>";
echo "<p>Server IP: " . $_SERVER['SERVER_ADDR'] . "</p>";
echo "<p>Request Time: " . date('Y-m-d H:i:s') . "</p>";
?>
```

4. Save the file and navigate to `http://your-load-balancer-dns/server-info.php`
5. Refresh the page multiple times and observe different hostnames appearing

**Test Automatic Recovery**:
To verify that your infrastructure automatically recovers from server failures:

1. Note the instance IDs of your currently running servers
2. Manually terminate one instance through the EC2 console
3. Watch the Auto Scaling Group automatically detect the failure and launch a replacement
4. Verify that your website remains accessible throughout this process
5. Confirm that the new instance appears in the load balancer target group

**What This Demonstrates**: This test proves that your architecture has no single points of failure. Even when individual servers fail, the system maintains availability while automatically healing itself.

### 12.5 Test Auto Scaling - Validating Dynamic Capacity

**Generate Artificial Load**:
To test your scaling policies, you need to create CPU load that exceeds your 70% threshold:

1. SSH to one of your running instances
2. Install the stress testing utility: `sudo yum install -y stress`
3. Generate CPU load: `stress --cpu 2 --timeout 600s`

This command creates high CPU usage for 10 minutes, simulating a traffic spike or resource-intensive operation.

**Monitor Scaling Activity**:

1. Navigate to CloudWatch Console → Metrics → EC2 → By Auto Scaling Group
2. Select your Auto Scaling Group and view the CPU utilization metric
3. Watch as CPU usage rises above your 70% threshold
4. Monitor the Auto Scaling Group activity tab for scaling events
5. Observe new instances launching in the EC2 console

![CloudWatch CPU](img/cloudwatch-cpu.png)

**Expected Timeline**:

- **Minutes 1-2**: CPU metrics show increased utilization
- **Minutes 3-4**: Auto Scaling Group triggers scaling policy
- **Minutes 4-7**: New instances launch and complete initialization
- **Minutes 8-10**: New instances pass health checks and begin receiving traffic
- **Minutes 15-20**: After stress test ends, CPU drops and instances may be terminated

**Understanding Scaling Behavior**: The scaling system is designed to be conservative to prevent rapid oscillations. It waits for sustained metric changes before taking action, then allows time for new instances to impact the overall metrics before making additional scaling decisions.

---

## Security Architecture Deep Dive - Understanding Your Protection Layers

### Network-Level Security (Foundation Layer)

**VPC Boundary Protection**: Your Virtual Private Cloud creates an isolated network environment that's completely separate from other AWS customers and the public internet. This isolation is enforced at the hypervisor level, providing the same security boundaries as physical network separation.

**Subnet-Based Segregation**: By dividing your VPC into public and private subnets, you've implemented network segmentation that controls traffic flow at the network level. Public subnets can initiate connections to and receive connections from the internet, while private subnets can only initiate outbound connections through the NAT Gateway.

**Route Table Controls**: Your custom route tables act as network-level traffic directors, ensuring that traffic can only flow through explicitly configured paths. Private subnets cannot accidentally become internet-accessible because there's no route to the Internet Gateway in their route table.

### Application-Level Security (Service Layer)

**Security Groups as Stateful Firewalls**: Unlike traditional network firewalls that examine packets in isolation, Security Groups maintain connection state information. When they allow an inbound connection, they automatically allow the return traffic, but they prevent new inbound connections that weren't initiated from inside.

**Principle of Least Privilege**: Each security group only allows the minimum access necessary for functionality. Your database security group only accepts connections from web servers, not from the entire internet or even the entire VPC.

**Defense in Depth**: Multiple overlapping security layers mean that if one security control fails, others remain in place. Even if someone bypassed the load balancer somehow, the web server security groups would still prevent unauthorized access.

### Data-Level Security (Information Protection)

**Encryption at Rest**: When enabled, RDS encryption protects your data even if someone gains physical access to AWS storage devices. The encryption is transparent to your application but provides strong protection for stored information.

**Encryption in Transit**: All communication between your web servers and RDS database occurs over encrypted connections, preventing eavesdropping on database queries and results.

**Backup Security**: RDS automated backups are encrypted with the same keys as the primary database, ensuring that backup data receives the same protection level as production data.

---

## Performance and Scalability Architecture

### Horizontal vs Vertical Scaling Strategy

Your architecture implements horizontal scaling (adding more servers) rather than vertical scaling (making servers bigger). This approach provides several advantages:

**Better Fault Tolerance**: Multiple smaller servers mean that failure of any single server has less impact than failure of one large server handling all traffic.

**More Granular Cost Control**: You can add exactly the capacity needed rather than jumping to the next larger instance size.

**Geographic Distribution**: Multiple instances can potentially be distributed across Availability Zones more evenly than a single large instance.

### Auto Scaling Intelligence

**Predictive Scaling Behavior**: Your target tracking policy doesn't just react to problems; it anticipates them. By maintaining 70% average CPU utilization, the system ensures there's always capacity available for sudden spikes while new instances launch.

**Gradual Scaling Approach**: Rather than adding one instance at a time, the target tracking algorithm calculates the optimal number of instances needed to reach the target metric, providing more responsive scaling.

**Scale-Down Protection**: The system includes built-in protections against rapid scale-down actions that could impact availability, ensuring that scaling decisions don't compromise user experience.

### Shared Storage Strategy

**Consistent Content Delivery**: EFS ensures that all web servers have access to identical WordPress files, eliminating common problems where user uploads or plugin installations only exist on some servers.

**Simplified Deployment**: When you need to install WordPress plugins, update themes, or modify configurations, changes made through any server are immediately available to all servers.

**Automatic Backup Integration**: EFS can be configured with automatic backup policies, ensuring that your WordPress customizations, uploaded media, and configuration files are protected independently of your database backups.

---

## Cost Optimization Deep Dive

### Understanding Your Cost Structure

**Fixed Monthly Costs** (regardless of traffic):

- **Application Load Balancer**: Approximately $22.50 per month plus data processing charges
- **NAT Gateway**: Approximately $45 per month plus data transfer charges
- **RDS Instance**: Varies significantly based on instance class and storage
- **EFS Storage**: $0.30 per GB per month for standard storage class

**Variable Costs** (scale with usage):

- **EC2 Instances**: Only charged for running time, scales with Auto Scaling
- **Data Transfer**: Between AWS services and out to internet
- **RDS Storage**: Grows with database size and backup retention

### Optimization Strategies

**Right-Sizing Approach**: Start with smaller instance types and use CloudWatch metrics to determine if larger instances are needed. Many WordPress sites run effectively on t3.small instances, and you can always scale up based on actual performance data.

**Reserved Instance Planning**: For predictable workloads, purchasing Reserved Instances can reduce costs by 30-60%. However, wait until you have several months of usage data to determine your baseline capacity needs.

**EFS Intelligent Tiering**: Enable EFS Intelligent Tiering to automatically move infrequently accessed files to lower-cost storage classes. This is particularly effective for WordPress sites with many uploaded images that aren't accessed regularly.

**Scheduled Scaling**: If your client's business has predictable traffic patterns (higher during business hours, lower on weekends), you can implement scheduled scaling policies to pre-emptively adjust capacity and avoid reactive scaling costs.

---

This completes the comprehensive WordPress deployment guide. Your architecture now provides enterprise-grade availability, security, and scalability while maintaining cost-effectiveness and operational simplicity. The foundation you've built can support significant growth and can be enhanced with additional AWS services as requirements evolve.
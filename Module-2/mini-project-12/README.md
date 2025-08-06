# AWS Security Groups and Network ACLs Configuration Guide

## Overview

This guide provides comprehensive instructions for configuring AWS Security Groups and Network Access Control Lists (NACLs) to implement proper network security controls within your AWS infrastructure. The documentation covers practical implementation, troubleshooting, and best practices for managing traffic flow in AWS environments.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Core Concepts](#core-concepts)
- [Security Groups Configuration](#security-groups-configuration)
- [Network ACLs Configuration](#network-acls-configuration)
- [Testing and Validation](#testing-and-validation)
- [Troubleshooting](#troubleshooting)
- [Code Snippets](#code-snippets)
- [Best Practices](#best-practices)

## Prerequisites

- AWS account with appropriate IAM permissions
- Existing VPC with public subnet
- EC2 instance deployed in the public subnet
- Basic understanding of networking concepts
- AWS CLI configured (optional but recommended)

## Core Concepts

### Security Groups

Security Groups function as virtual firewalls operating at the instance level. They control inbound and outbound traffic through stateful rules, automatically allowing return traffic for established connections.

**Key Characteristics:**

- **Stateful**: Return traffic automatically allowed
- **Instance-level**: Applied directly to EC2 instances
- **Allow-only rules**: No explicit deny rules
- **Default behavior**: Deny all inbound, allow all outbound

### Network Access Control Lists (NACLs)

NACLs operate as subnet-level firewalls, providing an additional layer of security. Unlike Security Groups, NACLs are stateless and require explicit rules for both inbound and outbound traffic.

**Key Characteristics:**

- **Stateless**: Separate rules required for inbound and outbound traffic
- **Subnet-level**: Applied to entire subnets
- **Allow and deny rules**: Explicit allow/deny configurations
- **Rule precedence**: Lower rule numbers take priority

## Security Groups Configuration

### Step 1: Create Security Group

Navigate to the EC2 console and access Security Groups from the sidebar.

![Security Groups Navigation](placeholder-security-groups-nav.png)

```bash
# AWS CLI command to create security group
aws ec2 create-security-group \
    --group-name web-server-sg \
    --description "Security group for web server" \
    --vpc-id vpc-xxxxxxxxx
```

### Step 2: Configure Inbound Rules

Configure rules to allow HTTP and SSH access:

![Inbound Rules Configuration](placeholder-inbound-rules.png)

```bash
# Add HTTP rule
aws ec2 authorize-security-group-ingress \
    --group-id sg-xxxxxxxxx \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

# Add SSH rule
aws ec2 authorize-security-group-ingress \
    --group-id sg-xxxxxxxxx \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0
```

### Step 3: Configure Outbound Rules

Default outbound rules allow all traffic. Modify as needed for security requirements:

![Outbound Rules Configuration](placeholder-outbound-rules.png)

```bash
# Remove default outbound rule (if needed)
aws ec2 revoke-security-group-egress \
    --group-id sg-xxxxxxxxx \
    --protocol all \
    --cidr 0.0.0.0/0

# Add specific outbound rule
aws ec2 authorize-security-group-egress \
    --group-id sg-xxxxxxxxx \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0
```

### Step 4: Attach Security Group to Instance

![Security Group Attachment](placeholder-sg-attachment.png)

```bash
# Modify instance security groups
aws ec2 modify-instance-attribute \
    --instance-id i-xxxxxxxxx \
    --groups sg-xxxxxxxxx
```

## Network ACLs Configuration

### Step 1: Create Custom NACL

Access Network ACLs from the VPC console:

![NACL Creation](placeholder-nacl-creation.png)

```bash
# Create network ACL
aws ec2 create-network-acl \
    --vpc-id vpc-xxxxxxxxx \
    --tag-specifications 'ResourceType=network-acl,Tags=[{Key=Name,Value=web-nacl}]'
```

### Step 2: Configure Inbound Rules

![NACL Inbound Rules](placeholder-nacl-inbound.png)

```bash
# Add inbound HTTP rule
aws ec2 create-network-acl-entry \
    --network-acl-id acl-xxxxxxxxx \
    --rule-number 100 \
    --protocol tcp \
    --port-range From=80,To=80 \
    --cidr-block 0.0.0.0/0 \
    --rule-action allow

# Add inbound SSH rule
aws ec2 create-network-acl-entry \
    --network-acl-id acl-xxxxxxxxx \
    --rule-number 110 \
    --protocol tcp \
    --port-range From=22,To=22 \
    --cidr-block 0.0.0.0/0 \
    --rule-action allow
```

### Step 3: Configure Outbound Rules

![NACL Outbound Rules](placeholder-nacl-outbound.png)

```bash
# Add outbound HTTP rule
aws ec2 create-network-acl-entry \
    --network-acl-id acl-xxxxxxxxx \
    --rule-number 100 \
    --protocol tcp \
    --port-range From=80,To=80 \
    --cidr-block 0.0.0.0/0 \
    --rule-action allow \
    --egress

# Add ephemeral ports for return traffic
aws ec2 create-network-acl-entry \
    --network-acl-id acl-xxxxxxxxx \
    --rule-number 110 \
    --protocol tcp \
    --port-range From=1024,To=65535 \
    --cidr-block 0.0.0.0/0 \
    --rule-action allow \
    --egress
```

### Step 4: Associate NACL with Subnet

![NACL Subnet Association](placeholder-nacl-association.png)

```bash
# Associate NACL with subnet
aws ec2 associate-network-acl \
    --network-acl-id acl-xxxxxxxxx \
    --subnet-id subnet-xxxxxxxxx
```

## Testing and Validation

### Web Server Accessibility Test

Test HTTP access to your web server:

![Web Server Test](placeholder-web-test.png)

```bash
# Test HTTP connectivity
curl -I http://YOUR_PUBLIC_IP

# Expected response
HTTP/1.1 200 OK
Server: nginx/1.18.0
Date: Wed, 06 Aug 2025 10:00:00 GMT
Content-Type: text/html
```

### SSH Connectivity Test

```bash
# Test SSH access
ssh -i your-key.pem ec2-user@YOUR_PUBLIC_IP

# Connection timeout indicates blocked access
ssh: connect to host YOUR_PUBLIC_IP port 22: Connection timed out
```

### Network Connectivity Diagnostics

```bash
# Test specific ports
telnet YOUR_PUBLIC_IP 80
telnet YOUR_PUBLIC_IP 22

# Check security group rules
aws ec2 describe-security-groups --group-ids sg-xxxxxxxxx

# Check NACL rules
aws ec2 describe-network-acls --network-acl-ids acl-xxxxxxxxx
```

## Troubleshooting

### Common Issues and Solutions

#### Issue 1: Website Not Accessible Despite HTTP Rule

**Symptoms:** Browser shows "This site can't be reached" or connection timeout.

**Cause:** Missing inbound HTTP rule in Security Group or NACL blocking traffic.

**Solution:**

```bash
# Verify Security Group rules
aws ec2 describe-security-groups --group-ids sg-xxxxxxxxx --query 'SecurityGroups[0].IpPermissions'

# Add HTTP rule if missing
aws ec2 authorize-security-group-ingress \
    --group-id sg-xxxxxxxxx \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0
```

#### Issue 2: SSH Connection Refused

**Symptoms:** "Connection refused" or "Permission denied" errors.

**Cause:** SSH service not running or Security Group missing SSH rule.

**Solution:**

```bash
# Check SSH rule exists
aws ec2 describe-security-groups --group-ids sg-xxxxxxxxx \
    --query 'SecurityGroups[0].IpPermissions[?FromPort==`22`]'

# Verify SSH service status (from EC2 console)
sudo systemctl status ssh
sudo systemctl start ssh
```

#### Issue 3: NACL Configuration Not Working

**Symptoms:** Traffic blocked despite Security Group allowing access.

**Cause:** NACL rules misconfigured or missing ephemeral port rules.

**Solution:**

```bash
# Check current NACL associations
aws ec2 describe-network-acls --filters "Name=association.subnet-id,Values=subnet-xxxxxxxxx"

# Add ephemeral ports for outbound traffic
aws ec2 create-network-acl-entry \
    --network-acl-id acl-xxxxxxxxx \
    --rule-number 200 \
    --protocol tcp \
    --port-range From=1024,To=65535 \
    --cidr-block 0.0.0.0/0 \
    --rule-action allow \
    --egress
```

#### Issue 4: Intermittent Connection Issues

**Symptoms:** Some connections work while others fail randomly.

**Cause:** NACL rule conflicts or overlapping CIDR blocks.

**Solution:**

```bash
# Review all NACL rules for conflicts
aws ec2 describe-network-acls --network-acl-ids acl-xxxxxxxxx \
    --query 'NetworkAcls[0].Entries' --output table

# Remove conflicting rules
aws ec2 delete-network-acl-entry \
    --network-acl-id acl-xxxxxxxxx \
    --rule-number RULE_NUMBER
```

### Diagnostic Commands

```bash
# Check instance security groups
aws ec2 describe-instances --instance-ids i-xxxxxxxxx \
    --query 'Reservations[0].Instances[0].SecurityGroups'

# Verify NACL associations
aws ec2 describe-subnets --subnet-ids subnet-xxxxxxxxx \
    --query 'Subnets[0].NetworkAclAssociationId'

# Test port connectivity
nc -zv YOUR_PUBLIC_IP 80
nc -zv YOUR_PUBLIC_IP 22
```

## Code Snippets

### Python Script for Security Group Validation

```python
import boto3

def validate_security_group(group_id):
    ec2 = boto3.client('ec2')

    try:
        response = ec2.describe_security_groups(GroupIds=[group_id])
        sg = response['SecurityGroups'][0]

        print(f"Security Group: {sg['GroupName']}")
        print("Inbound Rules:")
        for rule in sg['IpPermissions']:
            print(f"  Protocol: {rule.get('IpProtocol')}")
            print(f"  Port: {rule.get('FromPort', 'All')}")
            print(f"  Source: {rule.get('IpRanges', [{}])[0].get('CidrIp', 'N/A')}")

    except Exception as e:
        print(f"Error: {e}")

# Usage
validate_security_group('sg-xxxxxxxxx')
```

### Bash Script for NACL Rule Creation

```bash
#!/bin/bash

NACL_ID="acl-xxxxxxxxx"
VPC_CIDR="10.0.0.0/16"

create_nacl_rules() {
    # HTTP inbound
    aws ec2 create-network-acl-entry \
        --network-acl-id $NACL_ID \
        --rule-number 100 \
        --protocol tcp \
        --port-range From=80,To=80 \
        --cidr-block 0.0.0.0/0 \
        --rule-action allow

    # SSH inbound
    aws ec2 create-network-acl-entry \
        --network-acl-id $NACL_ID \
        --rule-number 110 \
        --protocol tcp \
        --port-range From=22,To=22 \
        --cidr-block 0.0.0.0/0 \
        --rule-action allow

    # Outbound HTTP
    aws ec2 create-network-acl-entry \
        --network-acl-id $NACL_ID \
        --rule-number 100 \
        --protocol tcp \
        --port-range From=80,To=80 \
        --cidr-block 0.0.0.0/0 \
        --rule-action allow \
        --egress

    # Ephemeral ports
    aws ec2 create-network-acl-entry \
        --network-acl-id $NACL_ID \
        --rule-number 110 \
        --protocol tcp \
        --port-range From=1024,To=65535 \
        --cidr-block 0.0.0.0/0 \
        --rule-action allow \
        --egress

    echo "NACL rules created successfully"
}

create_nacl_rules
```

## Best Practices

### Security Group Best Practices

- Apply the principle of least privilege when configuring rules
- Use specific IP ranges instead of 0.0.0.0/0 when possible
- Document rule purposes and review regularly
- Group similar instances under appropriate security groups
- Monitor security group changes through CloudTrail

### NACL Best Practices

- Use NACLs as an additional layer of defense, not primary security control
- Plan rule numbers carefully, leaving gaps for future insertions
- Remember to configure ephemeral ports for return traffic
- Test thoroughly when implementing custom NACLs
- Document rule purposes and review configurations regularly

### General Networking Best Practices

- Implement defense in depth with multiple security layers
- Monitor network traffic through VPC Flow Logs
- Use AWS Config to track configuration changes
- Implement proper logging and monitoring
- Regular security audits and rule reviews

## Conclusion

Proper configuration of Security Groups and NACLs provides robust network security for AWS infrastructure. Security Groups offer stateful, instance-level protection, while NACLs provide stateless, subnet-level controls. Understanding their differences and implementing both layers creates comprehensive network security.

Regular monitoring, testing, and adherence to best practices ensure continued security effectiveness. The troubleshooting guidance and code snippets provided facilitate quick resolution of common configuration issues and enable automation of security configurations.

Remember that network security is an ongoing process requiring regular review and updates to maintain effectiveness against evolving threats and changing infrastructure requirements.

# AWS Security Groups and NACLs - Complete Guide

## Overview

Security Groups and Network Access Control Lists (NACLs) are AWS's primary network security mechanisms. This guide covers configuration, testing, and troubleshooting of both components.

**Duration:** 2 hours  
**Prerequisites:** Basic AWS knowledge, active VPC with EC2 instance

## Key Concepts

### Security Groups

- **Instance-level firewall** - Controls traffic to/from individual EC2 instances
- **Stateful** - Return traffic automatically allowed
- **Allow rules only** - No explicit deny rules
- **Default behavior** - Deny all inbound, allow all outbound

### Network ACLs (NACLs)

- **Subnet-level firewall** - Controls traffic entering/leaving subnets
- **Stateless** - Must configure inbound and outbound rules separately
- **Allow/Deny rules** - Explicit allow and deny capabilities
- **Default behavior** - Allow all traffic (default NACL)

## Practical Implementation

### Part 1: Security Groups Configuration

#### Initial Setup Check

First, verify your EC2 instance and current security group configuration:

```bash
# Test website accessibility (replace with your public IP)
curl -I http://54.255.228.191
```

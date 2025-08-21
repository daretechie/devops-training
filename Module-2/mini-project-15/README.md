# AWS Auto Scaling with Application Load Balancer Using Launch Templates

## Project Overview

This project demonstrates the implementation of a robust, self-healing web application infrastructure on AWS using Auto Scaling Groups, Application Load Balancers, and Launch Templates. The system automatically adjusts the number of EC2 instances based on CPU utilization, ensuring optimal performance during traffic fluctuations while maintaining cost efficiency.

### Architecture Diagram Placeholder

```
[Internet] → [Application Load Balancer] → [Target Group] → [Auto Scaling Group]
                                                                ↓
                                                    [EC2 Instance 1] [EC2 Instance 2] [EC2 Instance N]
                                                                ↑
                                                        [Launch Template]
```

## Learning Objectives Achieved

- ✅ Created and configured Launch Templates for consistent instance deployment
- ✅ Implemented Auto Scaling Groups with intelligent scaling policies
- ✅ Integrated Application Load Balancers for traffic distribution
- ✅ Configured target groups for health monitoring and traffic routing
- ✅ Established security groups with proper access controls
- ✅ Performed comprehensive load testing and scaling validation
- ✅ Troubleshot network connectivity and security configurations

## Infrastructure Components

### VPC Foundation

- **VPC ID**: `vpc-05ff09e0cc9c8f7d2` (Default VPC)
- **Availability Zones Used**: us-east-1a, us-east-1b, us-east-1c
- **Subnets**:
  - Primary: `subnet-0365fb1869cd229bd` (us-east-1a)
  - Secondary: `subnet-0cc5ea0e4ef37319b` (us-east-1b)
  - Optional: `subnet-01da79a0136e4778d` (us-east-1c)
- **Internet Gateway**: `igw-07f8b6645ef3ca8f1`

### Security Configuration

- **Security Group**: `web-server-sg`
  - HTTP (80): 0.0.0.0/0 (Public web access)
  - SSH (22): Your-IP/32 (Administrative access)

## Step-by-Step Implementation

### Phase 1: Launch Template Creation

The Launch Template serves as the blueprint for all instances that Auto Scaling will create. Think of it as a recipe that ensures every new instance is configured identically.

#### Template Configuration Details

```yaml
Template Name: web-server-autoscaling-template
Description: Initial template for auto-scaling web servers with Apache
AMI: Amazon Linux 2023 (Latest)
Instance Type: t3.micro
Security Group: web-server-sg
Key Pair: MyKey (for SSH access)
```

#### User Data Script

This script runs automatically on every new instance launch, transforming a basic AMI into a fully functional web server:

```bash
#!/bin/bash
# System updates and Apache installation
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Create informative webpage for load balancer testing
echo "<h1>Web Server $(hostname -f)</h1>" > /var/www/html/index.html
echo "<p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>" >> /var/www/html/index.html
echo "<p>Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>" >> /var/www/html/index.html

# Install stress testing tools for scaling validation
amazon-linux-extras install epel -y
yum install stress -y

# Create convenient stress test script
cat << 'EOF' > /home/ec2-user/stress-test.sh
#!/bin/bash
echo "Starting CPU stress test for 10 minutes..."
stress --cpu 4 --timeout 600
echo "Stress test completed!"
EOF
chmod +x /home/ec2-user/stress-test.sh
```

**Why This Script Matters**: The user data script ensures every instance is immediately productive upon launch. The metadata queries create a unique identifier for each instance, helping you verify that the load balancer is distributing traffic properly. The stress testing tools provide a controlled way to simulate high CPU usage for scaling tests.

### Phase 2: Application Load Balancer Setup

The Application Load Balancer acts as the intelligent traffic distributor, continuously monitoring instance health and routing requests only to healthy instances.

#### Load Balancer Configuration

```yaml
Name: web-server-alb
Scheme: Internet-facing
IP Address Type: IPv4
VPC: vpc-05ff09e0cc9c8f7d2
Availability Zones: us-east-1a, us-east-1b
Security Group: web-server-sg
```

#### Target Group Configuration

The target group defines how the load balancer should treat your instances:

```yaml
Target Group Name: web-server-targets
Target Type: Instances
Protocol: HTTP
Port: 80
VPC: vpc-05ff09e0cc9c8f7d2
Health Check Path: /
Health Check Protocol: HTTP
Healthy Threshold: 2 consecutive successes
Unhealthy Threshold: 3 consecutive failures
Timeout: 5 seconds
Interval: 30 seconds
Success Codes: 200
```

**Health Check Strategy**: The health check configuration balances responsiveness with stability. Two consecutive successes ensure instances are truly ready before receiving traffic, while three failures prevent temporary network hiccups from unnecessarily removing healthy instances.

### Phase 3: Auto Scaling Group Configuration

The Auto Scaling Group provides the intelligence to automatically adjust capacity based on demand.

#### Scaling Configuration

```yaml
Auto Scaling Group Name: web-server-asg
Launch Template: web-server-autoscaling-template (Latest version)
VPC: vpc-05ff09e0cc9c8f7d2
Subnets: Multi-AZ distribution for high availability
Desired Capacity: 2 instances
Minimum Capacity: 1 instance
Maximum Capacity: 4 instances
Health Check Grace Period: 300 seconds
Health Check Type: ELB (Load balancer health checks)
```

#### Scaling Policies

Target tracking scaling provides automatic, intelligent capacity management:

```yaml
Policy Name: maintain-cpu-utilization
Metric: Average CPU Utilization
Target Value: 60%
Instance Warmup: 300 seconds
```

**Policy Logic**: The 60% CPU target provides optimal resource utilization while maintaining headroom for traffic spikes. The 300-second warmup period accounts for instance boot time and application initialization before the instance receives full traffic load.

## Testing and Validation

### Baseline Testing

Before load testing, verify your infrastructure is working correctly:

1. **Instance Health Check**: Confirm both instances show "Healthy" in the target group
2. **Load Balancer Functionality**: Access the ALB DNS name multiple times, observing different instance IDs
3. **Multi-AZ Distribution**: Verify instances are launching across different availability zones

### Load Testing Procedure

#### Generating CPU Load

Connect to an instance via SSH and execute the stress test:

```bash
# Connect to instance
ssh -i "MyKey.pem" ec2-user@[instance-public-ip]

# Execute stress test
./stress-test.sh

# Alternative manual command
stress --cpu 4 --timeout 600
```

#### Monitoring Scaling Events

While stress testing, monitor these key metrics:

1. **Auto Scaling Activity**: Watch the "Activity" tab for scaling events
2. **CloudWatch Metrics**: Monitor CPU utilization across instances
3. **Target Group Health**: Observe new instances registering and becoming healthy
4. **Load Distribution**: Verify traffic spreading across all healthy instances

### Expected Scaling Behavior

**Scale-Out Sequence**:

1. CPU utilization exceeds 60% threshold (typically within 1-2 minutes)
2. Auto Scaling initiates new instance launch (visible in Activity tab)
3. New instance boots and runs user data script (2-3 minutes)
4. Instance passes health checks and receives traffic (additional 1-2 minutes)
5. CPU utilization normalizes across expanded fleet

**Scale-In Sequence**:

1. CPU utilization drops below 60% when stress test ends
2. Cooldown period prevents immediate scale-in (5-10 minutes)
3. Auto Scaling terminates excess instances
4. Fleet returns to desired capacity of 2 instances

## Troubleshooting Guide

### Common Issues and Solutions

#### SSH Connection Timeouts

**Symptom**: `ssh: connect to host [hostname] port 22: Connection timed out`

**Root Cause**: Security group not allowing SSH access from your current IP address

**Solution Steps**:

1. Determine your current public IP address (search "what is my IP" in browser)
2. Navigate to EC2 → Security Groups → web-server-sg
3. Edit inbound rules to allow SSH (port 22) from your IP address with /32 suffix
4. Example: If your IP is 203.0.113.50, add rule for 203.0.113.50/32
5. Changes take effect immediately

**Prevention**: Use a static IP range if available, or document the need to update security groups when your IP changes

#### Instances Not Scaling Out

**Symptoms**: CPU utilization high but no new instances launching

**Diagnostic Steps**:

1. Check Auto Scaling Group activity history for error messages
2. Verify scaling policy is active and properly configured
3. Confirm maximum capacity hasn't been reached
4. Review CloudWatch metrics to ensure CPU data is being reported
5. Check service quotas for EC2 instances in your region

**Common Fixes**:

- Adjust scaling threshold if load patterns differ from expectations
- Increase maximum capacity if legitimate demand exceeds current limits
- Verify IAM permissions for Auto Scaling service

#### Health Check Failures

**Symptoms**: Instances launching but showing unhealthy in target group

**Diagnostic Steps**:

1. SSH into instance and verify Apache is running: `systemctl status httpd`
2. Test local web server response: `curl localhost`
3. Check security group allows HTTP traffic on port 80
4. Verify user data script completed successfully: `tail /var/log/cloud-init-output.log`

**Resolution**:

- Restart Apache service: `sudo systemctl restart httpd`
- Check firewall settings aren't blocking HTTP traffic
- Extend health check timeout if instances need more initialization time

#### Load Balancer Not Distributing Traffic

**Symptoms**: Always seeing same instance ID when accessing ALB

**Possible Causes**:

1. Browser caching responses
2. Only one instance healthy
3. Sticky sessions enabled (not default for ALB)

**Solutions**:

- Use different browsers or incognito mode for testing
- Check target group health status
- Verify multiple instances are registered and healthy

### Monitoring and Alerts

#### Key Metrics to Watch

- **CPU Utilization**: Primary scaling trigger
- **Request Count**: Traffic volume indicator
- **Target Response Time**: Application performance measure
- **Healthy Host Count**: Available capacity indicator

#### CloudWatch Dashboard Setup

Create a custom dashboard including:

- Auto Scaling Group metrics (desired vs current capacity)
- Individual instance CPU utilization
- Load balancer request count and latency
- Target group healthy host count

## Cost Optimization Strategies

### Right-Sizing Instances

Monitor CPU and memory utilization to ensure t3.micro instances are appropriately sized. Consider t3.nano for very light workloads or t3.small for consistently higher utilization.

### Scaling Policy Tuning

Adjust target CPU utilization based on actual application behavior. Applications that handle traffic spikes well might use 70-75% targets, while those sensitive to latency might use 50-55%.

### Scheduled Scaling

For predictable traffic patterns, implement scheduled scaling policies to pre-scale before known busy periods, reducing response time to demand changes.

## Security Best Practices Implemented

### Network Security

- Security groups follow principle of least privilege
- SSH access restricted to specific IP addresses
- HTTP access only on required port 80
- No unnecessary ports exposed

### Access Control

- Key-based authentication for SSH access
- No passwords stored in user data or configuration
- IAM roles used for service-to-service communication

### Monitoring and Logging

- CloudTrail enabled for API call auditing
- VPC Flow Logs for network traffic analysis
- CloudWatch Logs for application and system logs

## Learning Outcomes and Reflections

### Technical Skills Developed

This project provided hands-on experience with core AWS services that form the backbone of scalable web applications. Understanding how Launch Templates ensure consistency, how Auto Scaling Groups make intelligent capacity decisions, and how Application Load Balancers distribute traffic are fundamental skills for cloud architecture.

### Problem-Solving Experience

The SSH connectivity troubleshooting demonstrated the importance of understanding security group behavior and IP address management in cloud environments. This type of systematic problem-solving approach applies to many cloud computing challenges.

### Architectural Understanding

The project illustrates how loose coupling between services creates flexible, maintainable systems. Each component (Launch Template, Auto Scaling Group, Load Balancer) has clear responsibilities and well-defined interfaces with other components.

## Next Steps and Extensions

### Immediate Enhancements

- Implement HTTPS with SSL/TLS certificates
- Add CloudWatch custom metrics for application-specific monitoring
- Configure SNS notifications for scaling events

### Advanced Improvements

- Multi-region deployment for disaster recovery
- Blue/green deployment strategies using multiple Auto Scaling Groups
- Container-based deployment using ECS or EKS
- Database integration with RDS and connection pooling

### Production Readiness

- Implement comprehensive logging and monitoring
- Set up automated backup strategies
- Develop disaster recovery procedures
- Establish security scanning and compliance checking

## Resources and Documentation

### AWS Documentation References

- [Auto Scaling User Guide](https://docs.aws.amazon.com/autoscaling/ec2/userguide/)
- [Application Load Balancer Guide](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/)
- [Launch Template Documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-templates.html)

### Useful Commands Reference

```bash
# SSH connection
ssh -i "MyKey.pem" ec2-user@[instance-ip]

# Check system status
systemctl status httpd
curl localhost

# Generate CPU load
stress --cpu 4 --timeout 600

# Monitor system resources
top
htop
iostat
```

### AWS CLI Commands for Management

```bash
# Describe Auto Scaling Groups
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names web-server-asg

# Describe scaling activities
aws autoscaling describe-scaling-activities --auto-scaling-group-name web-server-asg

# Manually trigger scaling (for testing)
aws autoscaling set-desired-capacity --auto-scaling-group-name web-server-asg --desired-capacity 3
```

## Project Timeline and Effort

**Total Implementation Time**: Approximately 2-3 hours including testing
**Key Phases**:

- Launch Template Creation: 30 minutes
- Auto Scaling Group Setup: 45 minutes
- Load Balancer Configuration: 30 minutes
- Testing and Validation: 45-60 minutes
- Troubleshooting and Documentation: 30 minutes

## Conclusion

This project successfully demonstrates the power of AWS Auto Scaling combined with Application Load Balancers to create resilient, scalable web applications. The infrastructure automatically adapts to changing demand while maintaining consistent performance and optimizing costs.

The hands-on experience gained through implementation, testing, and troubleshooting provides a solid foundation for building production-ready applications in the AWS cloud. The systematic approach to documentation and problem-solving developed here will prove valuable for future cloud architecture projects.

---

**Project Completed By**: Dare Adeleke  
**Date**: 21-08-2025
**AWS Region**: us-east-1

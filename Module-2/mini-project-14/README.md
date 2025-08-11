## DevOps Project README

### Project Summary

This project provides a basic introduction to creating AWS resources using shell scripting, focusing on two key services: EC2 and S3. You'll learn to write functions to provision EC2 instances and create S3 buckets, leveraging the AWS CLI and basic shell scripting concepts like arrays and loops.

---

### Prerequisites

Before you begin, ensure you have the following installed and configured:

- **AWS CLI:** The command-line interface for managing AWS services.
- **AWS credentials:** Your AWS access keys must be configured to allow the CLI to interact with your account.
- **A Key Pair:** You must create an EC2 key pair in your desired region from the AWS console. The script will reference this key pair.

---

### Project Breakdown

#### 1\. Functions to Provision AWS Resources

The project is built around two main functions: `create_ec2_instances()` and `create_s3_buckets()`.

##### **`create_ec2_instances()`**

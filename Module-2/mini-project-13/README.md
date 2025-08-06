# 🚀 Shell Scripting + Cloud Foundations: 5 Essential Skills for AWS Automation

This mini project lays the foundation for integrating **Shell Scripting** with **Cloud Computing (AWS)**. The focus is on mastering 5 critical scripting skills in a real-world scenario: automating EC2 and S3 resource provisioning for a data-driven startup.

---

## 🎯 Objective

Develop a modular shell script using:

- ✅ **Functions**
- ✅ **Arrays**
- ✅ **Environment Variables**
- ✅ **Command-Line Arguments**
- ✅ **Error Handling**

This script will prepare AWS resources (EC2 and S3) required by DataWise Solutions to deploy analytical environments for clients.

---

## 📘 Use Case: DataWise Cloud Automation

A client of DataWise Solutions, an e-commerce startup, requires an automated solution to:

- Spin up EC2 instances for compute workloads
- Create S3 buckets to store customer interaction data

The script will automate both tasks while applying clean scripting patterns and safe error handling.

---

## 🔧 Skill Breakdown

### 1. 🧩 **Functions**

Structure code into reusable blocks:

```bash
create_ec2_instance() {
  # logic to call AWS CLI to provision instance
}
create_s3_bucket() {
  # logic to create and configure S3 bucket
}
```

![shell script with defined functions](./shell-script-with-defined-functions.png)

---

### 2. 📦 **Arrays**

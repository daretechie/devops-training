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

Track created resources dynamically:

```bash
declare -a created_instances
created_instances+=("instance-1-id")
```

Arrays help with logging, rollback, or monitoring status.

---

### 3. 🔐 **Environment Variables**

Secure and configure deployment with:

```bash
export AWS_REGION="us-east-1"
export INSTANCE_TYPE="t2.micro"
```

Avoid hardcoding. Store credentials in `.env` or use `aws configure`.

![environment variable usage](./environment-variable-usage.png)

---

### 4. ⚙️ **Command-Line Arguments**

Make scripts flexible:

```bash
./deploy.sh my-bucket-name t2.micro
```

Access with `$1`, `$2`, etc. Validate inputs for robustness:

```bash
[ -z \"$1\" ] && echo \"Missing bucket name\" && exit 1
```

---

### 5. 🛡️ **Error Handling**

Fail gracefully and inform the user:

```bash
aws ec2 run-instances ... || {
  echo \"EC2 instance creation failed\"
  exit 1
}
```

Use conditional checks, return codes (`$?`), and log errors for visibility.

![error captured and handled](./error-captured-and-handled.png)

---

# ⚙️ Implementation: `deploy.sh`

```bash
#!/bin/bash
set -euo pipefail
source .env

declare -a created_resources

log() {
  echo "[$(date +'%F %T')] $1" | tee -a logs/deploy.log
}

create_s3_bucket() {
  bucket_name=$1
  if aws s3api head-bucket --bucket "$bucket_name" 2>/dev/null; then
    log "S3 bucket '$bucket_name' already exists."
  else
    aws s3api create-bucket --bucket "$bucket_name" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION"
    log "Created S3 bucket: $bucket_name"
    created_resources+=("s3:$bucket_name")
  fi
}

create_ec2_instance() {
  ami_id=$1
  instance_type=$2
  key_name=$3
  response=$(aws ec2 run-instances --image-id "$ami_id" --count 1 --instance-type "$instance_type" --key-name "$key_name" --region "$AWS_REGION" --query 'Instances[0].InstanceId' --output text)
  if [[ -n "$response" ]]; then
    log "Launched EC2 instance: $response"
    created_resources+=("ec2:$response")
  else
    log "EC2 instance launch failed"
    exit 1
  fi
}

# Usage check
if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <bucket-name> <ami-id> <key-name>"
  exit 1
fi

bucket=$1
ami=$2
key=$3

log "Starting AWS resource provisioning..."
create_s3_bucket "$bucket"
create_ec2_instance "$ami" "$INSTANCE_TYPE" "$key"
log "Created resources: ${created_resources[*]}"
```

---

## 🔐 `.env` File (Example)

```bash
export AWS_REGION="us-east-1"
export INSTANCE_TYPE="t2.micro"
```

---

## 💡 Sample Execution

```bash
chmod +x deploy.sh
./deploy.sh my-bucket-name ami-0abcdef1234567890 my-keypair
```

---

## 🐞 Debugging Tips

Use `set -x` at the top to trace execution when troubleshooting:

```bash
#!/bin/bash
set -x
```

Turn off tracing with `set +x`. Helpful when debugging AWS CLI commands.

![debug output](./debug-output.png)

---

## 🧠 Concept Summary

| Concept        | Demo Section                              | Why It Matters                        |
| -------------- | ----------------------------------------- | ------------------------------------- |
| Functions      | `create_s3_bucket`, `create_ec2_instance` | Organizes logic into modular units    |
| Arrays         | `created_resources[]`                     | Tracks provisioned AWS resources      |
| Env Variables  | `.env` + `source`                         | Secure, reusable configuration        |
| Cmd Arguments  | `$1 $2 $3`                                | Allows flexible execution             |
| Error Handling | `set -euo pipefail`, exit codes           | Prevents silent failures, logs errors |

---

## 📌 What's Next?

This mini project sets the stage for writing a **production-grade shell script** that provisions AWS resources on-demand. The full implementation will follow next.

## ⚠️ Troubleshooting

| Issue                        | Cause                          | Solution                                          |
| ---------------------------- | ------------------------------ | ------------------------------------------------- |
| `aws: command not found`     | AWS CLI not installed          | `sudo apt install awscli`                         |
| `AccessDenied`               | Missing IAM permissions        | Attach proper policies to IAM user or role        |
| `InvalidParameter` on EC2    | Wrong AMI or config            | Use correct `ami-id`, `key-name`, `instance-type` |
| `S3 bucket exists` but fails | Bucket already exists globally | Use a unique name with timestamp                  |
| `script fails silently`      | No error handling              | Use \`set -euo pipefail\` to catch failures       |

---

## 📌 Conclusion

This project blends scripting skills with practical cloud automation. By mastering functions, arrays, env variables, arguments, and error handling, it’s possible to scale DevOps capabilities to manage real infrastructure tasks efficiently.

Next step: Expand the script to handle bulk operations, tagging, security groups, and dynamic scaling.

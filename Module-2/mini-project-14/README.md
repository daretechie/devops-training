# 🚀 Mini Project – Creating AWS Resources with Functions & Arrays

Automating AWS resource creation with functions and arrays makes provisioning faster, repeatable, and error-free.
This script provisions **EC2 instances** and **S3 buckets** using the AWS CLI, with dynamic parameters, environment detection, and validation.

---

## 🖥️ Function to Provision EC2 Instances

### Example Function:

```bash
#!/bin/bash

create_ec2_instances() {
    # Default values that can be overridden by parameters
    local instance_type="${1:-t2.micro}"  # Make instance type configurable
    local ami_id="${2:-ami-0cd59ecaf368e5ccf}"
    local count="${3:-2}"
    local region="${4:-eu-west-2}"

    aws ec2 run-instances \
        --image-id "$ami_id" \
        --instance-type "$instance_type" \
        --count $count \
        --key-name MyKeyPair \
        --region "$region"

    if [ $? -eq 0 ]; then
        echo "EC2 instances created successfully."
    else
        echo "Failed to create EC2 instances."
    fi
}

create_ec2_instances
```

![EC2 instances launched in AWS console](./images/ec2_instances.png)

---

## 📦 Function to Create Multiple S3 Buckets Using Arrays

### Example Function:

```bash
create_s3_buckets() {
    local company="datawise"
    local max_retries=3  # Maximum number of retry attempts
    local retry_delay=2  # Delay between retries in seconds
    local departments=("Marketing" "Sales" "HR" "Operations" "Media")

    for department in "${departments[@]}"; do
        local bucket_name="${company}-${department}-data-bucket"
        local attempt=1

        while [ $attempt -le $max_retries ]; do
            echo "Attempt $attempt to create bucket '$bucket_name'..."
            if aws s3api create-bucket --bucket "$bucket_name" --region eu-west-2; then
                echo "✅ Bucket '$bucket_name' created successfully."
                break
            else
                echo "⚠️  Failed to create bucket '$bucket_name' (Attempt $attempt/$max_retries)"
                if [ $attempt -eq $max_retries ]; then
                    echo "❌ Giving up on bucket '$bucket_name' after $max_retries attempts"
                else
                    echo "Retrying in $retry_delay seconds..."
                    sleep $retry_delay
                fi
                ((attempt++))
            fi
        done
    done
}

create_s3_buckets
```

![S3 bucket list in AWS console](./images/s3_buckets.png)

---

## 🧾 Full Script: `aws_resources.sh`

```bash
#!/bin/bash
set -euo pipefail
trap 'echo "❌ Error on line $LINENO" >&2' ERR

# ===== Input Parameters =====
ENVIRONMENT="${1:-}"
AMI_ID="${2:-}"
KEYPAIR="${3:-}"
REGION="${4:-}"
COUNT="${5:-}"
INSTANCE_TYPE="${6:-t2.micro}" # Default to t2.micro if not provided

# ===== Validate Parameters =====
if [ $# -ne 6 ]; then
  echo "Usage: $0 <environment> <ami_id> <keypair_name> <region> <instance_count> <instance_type>"
  exit 1
fi

# ===== Environment Check =====
activate_infra_environment() {
  case "$1" in
    local|testing|production) echo "✅ Running in $1 environment..." ;;
    *) echo "❌ Invalid environment: $1"; exit 2 ;;
  esac
}

# ===== AWS CLI Check =====
check_aws_cli() {
  if ! command -v aws &>/dev/null; then
    echo "❌ AWS CLI not installed. Install with 'sudo apt install awscli'."
    exit 1
  fi
}

# ===== AWS Profile Check =====
check_aws_profile() {
  if [ -z "${AWS_PROFILE:-}" ] && [ ! -f "$HOME/.aws/credentials" ]; then
    echo "❌ AWS credentials not found. Run 'aws configure'."
    exit 1
  fi
}

# ===== Function to Create EC2 Instances =====
create_ec2_instances() {
  echo "🔍 Checking key pair..."
  if ! aws ec2 describe-key-pairs --key-names "$KEYPAIR" --region "$REGION" >/dev/null 2>&1; then
    echo "❌ Key pair '$KEYPAIR' not found in region $REGION."
    exit 1
  fi

  echo "🚀 Launching $COUNT EC2 instance(s) of type $INSTANCE_TYPE..."
  if aws ec2 run-instances \
      --image-id "$AMI_ID" \
      --instance-type "$INSTANCE_TYPE" \
      --count "$COUNT" \
      --key-name "$KEYPAIR" \
      --region "$REGION"; then
    echo "✅ EC2 instances created."
  else
    echo "❌ Failed to create EC2 instances."
  fi
}

# ===== Function to Create S3 Buckets with Arrays & Retry Limit =====
create_s3_buckets() {
  company="datawise"
  departments=("Marketing" "Sales" "HR" "Operations" "Media")
  timestamp="$(date +%s)"
  MAX_RETRIES=3

  for department in "${departments[@]}"; do
    dep_norm="$(echo "$department" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '-')"
    bucket_name="${company}-${dep_norm}-${timestamp}-data-bucket"

    attempt=1
    success=false
    while [ $attempt -le $MAX_RETRIES ]; do
      echo "📦 Attempt $attempt: Creating bucket: $bucket_name..."
      if aws s3api create-bucket \
          --bucket "$bucket_name" \
          --region "$REGION" \
          --create-bucket-configuration LocationConstraint="$REGION"; then
        echo "✅ Bucket '$bucket_name' created."
        success=true
        break
      else
        echo "❌ Failed to create bucket '$bucket_name'. Retrying..."
        sleep 2
      fi
      attempt=$((attempt+1))
    done

    if [ "$success" = false ]; then
      echo "❌ Bucket '$bucket_name' could not be created after $MAX_RETRIES attempts."
    fi
  done
}

# ===== Execution Flow =====
activate_infra_environment "$ENVIRONMENT"
check_aws_cli
check_aws_profile
create_ec2_instances
create_s3_buckets

echo "🎯 Provisioning complete."
```

---

## 🖥️ Script Usage

```bash
chmod +x aws_resources.sh
./aws_resources.sh <environment> <ami_id> <keypair_name> <region> <instance_count>
```

Example:

```bash
./aws_resources.sh testing ami-0cd59ecaf368e5ccf MyKeyPair eu-west-2 2
```

# ===== Execution Flow =====

activate_infra_environment "$ENVIRONMENT"
check_aws_cli
check_aws_profile
create_ec2_instances
create_s3_buckets

echo "🎯 Provisioning complete."

---

## 💡 Key Concepts

- **Functions**: Encapsulate/reuse blocks of commands for EC2 and S3 creation.
- **Arrays**: Store multiple values (e.g., department names) and iterate over them with loops for bulk operations.
- **Dynamic Parameters**: AMI ID, region, key pair, and instance count passed via script arguments.
- **$?**: Checks the exit status of the last command to confirm success.
- **Retries**: Attempt bucket creation again if initial try fails.
- **Global Uniqueness in S3**: All S3 bucket names must be globally unique.

---

## � Bash & Script Feature Explanations

---

### **1. `set -euo pipefail`**

- **`-e`** → Exit script immediately if any command fails.
- **`-u`** → Treat unset variables as an error and exit.
- **`-o pipefail`** → If any command in a pipeline fails, the whole pipeline fails.
  **Why:** Prevents the script from continuing after an error.

---

### **2. `trap 'echo "❌ Error on line $LINENO"' ERR`**

- **`trap`** → Runs a command when a specific event occurs.
- **`ERR`** → Triggered when any command returns a non-zero exit code.
- **`$LINENO`** → Built-in variable showing the line number where the error happened.
  **Why:** Helps debug exactly where the script fails.

---

### **3. Parameter Variables**

```bash
ENVIRONMENT="${1:-}"
AMI_ID="${2:-}"
KEYPAIR="${3:-}"
REGION="${4:-}"
COUNT="${5:-}"
```

- `${1}`, `${2}` etc. → Arguments passed to the script from the command line.
- `:-` → Default to empty string if not provided.
  **Why:** Makes the script flexible — values are passed in when running, not hardcoded.

---

### **4. Environment Check Function**

```bash
case "$1" in
  local|testing|production) echo "✅ Running in $1 environment..." ;;
  *) echo "❌ Invalid environment: $1"; exit 2 ;;
esac
```

- **`case`** → Compares `$1` to given patterns (`local`, `testing`, `production`).
- **`exit 2`** → Stops the script with exit code 2 if invalid.
  **Why:** Prevents running in the wrong environment.

---

### **5. `command -v aws &>/dev/null`**

- Checks if `aws` CLI is installed.
- **`&>/dev/null`** → Suppresses output (both stdout and stderr).
  **Why:** Fails quietly if AWS CLI is missing.

---

### **6. `$?` Exit Status**

```bash
if [ $? -eq 0 ]; then
```

- `$?` → Exit code of the last command (`0` = success, non-zero = fail).
  **Why:** Confirms if EC2 or S3 creation worked before showing success message.

---

### **7. Arrays**

```bash
departments=("Marketing" "Sales" "HR" "Operations" "Media")
```

- Stores multiple values in a single variable.
  **Why:** Makes looping over department names easier.

---

### **8. Looping Through Arrays**

```bash
for department in "${departments[@]}"; do
```

- **`"${departments[@]}"`** → All elements in the array.
  **Why:** Allows creating multiple S3 buckets in one go.

---

### **9. Lowercasing & Replacing Spaces**

```bash
dep_norm="$(echo "$department" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '-')"
```

- Converts department name to lowercase and replaces spaces with `-`.
  **Why:** AWS bucket names must be lowercase and have no spaces.

---

### **10. Retry Logic for Buckets**

```bash
else
  echo "❌ Failed... Retrying..."
  sleep 2
```

- Waits for 2 seconds before retrying creation.
  **Why:** Helps in case of temporary AWS API issues.

---

## 🛠️ Troubleshooting

| Problem/Issue                                         | Cause                                                   | Solution/Fix                                                                                    |
| ----------------------------------------------------- | ------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `InvalidKeyPair.NotFound`                             | Key pair missing or not created in AWS                  | Create key pair in AWS console before running script / Create via AWS Console → EC2 → Key Pairs |
| `RequestLimitExceeded`                                | API call limit reached                                  | Wait and retry, or space out creation commands                                                  |
| `BucketAlreadyExists`                                 | S3 bucket names must be globally unique / Name conflict | Use a unique prefix/suffix or script uses timestamp to avoid clashes                            |
| `Unable to locate credentials`                        | AWS CLI not configured                                  | Run `aws configure`                                                                             |
| `AccessDenied`                                        | IAM permissions missing                                 | Add EC2 & S3 permissions to IAM user                                                            |
| `AWS CLI is not installed` / `command not found: aws` | CLI not available on the system                         | Install via `sudo apt install awscli` or with package manager                                   |
| `AWS profile not configured`                          | No credentials set                                      | Run `aws configure` to set access key and secret                                                |

📷 _[Insert screenshot: aws configure setup]_

---

## 🏁 Conclusion

Using AWS CLI with functions and arrays allows quick provisioning of multiple resources with minimal manual effort. This approach ensures consistent naming, reduces human error, and enables easy scaling of infrastructure. With EC2 provisioning and S3 bucket creation automated, the workflow is efficient and ready for production-level usage.

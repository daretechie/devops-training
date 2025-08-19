#!/bin/bash
set -euo pipefail
trap 'echo "Error on line $LINENO" >&2' ERR

# ===== Input Parameters =====
ENVIRONMENT="${1:-}"
AMI_ID="${2:-}"
KEYPAIR="${3:-}"
REGION="${4:-}"
COUNT="${5:-}"
INSTANCE_TYPE="${6:-t2.micro}"

# ===== Validate Parameters =====
if [ $# -ne 5 ]; then
  echo "Usage: $0 <environment> <ami_id> <keypair_name> <region> <instance_count> <instance_type>"
  exit 1
fi

# ===== Environment Check =====
activate_infra_environment() {
  case "$1" in
    local|testing|production) echo "Running in $1 environment..." ;;
    *) echo "Invalid environment: $1"; exit 2 ;;
  esac
}

# ===== AWS CLI Check =====
check_aws_cli() {
  if ! command -v aws &>/dev/null; then
    echo "AWS CLI not installed. Install with 'sudo apt install awscli'."
    exit 1
  fi
}

# ===== AWS Profile Check =====
check_aws_profile() {
  if [ -z "${AWS_PROFILE:-}" ] && [ ! -f "$HOME/.aws/credentials" ]; then
    echo "AWS credentials not found. Run 'aws configure'."
    exit 1
  fi
}

# ===== Function to Create EC2 Instances =====
create_ec2_instances() {
  echo "Checking key pair..."
  if ! aws ec2 describe-key-pairs --key-names "$KEYPAIR" --region "$REGION" >/dev/null 2>&1; then
    echo "Key pair '$KEYPAIR' not found in region $REGION."
    exit 1
  fi

  echo "Launching $COUNT EC2 instance(s) of the $INSTANCE_TYPE..."
  if aws ec2 run-instances \
      --image-id "$AMI_ID" \
      --instance-type "$INSTANCE_TYPE" \
      --count "$COUNT" \
      --key-name "$KEYPAIR" \
      --region "$REGION"; then
    echo "EC2 instances created."
  else
    echo "Failed to create EC2 instance."
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
      echo "Attempt $attempt: Creating bucket: $bucket_name..."
      if [ "$REGION" = "us-east-1" ]; then
        if aws s3api create-bucket \
            --bucket "$bucket_name" \
            --region "$REGION"; then
          echo "✅ Bucket '$bucket_name' created."
          success=true
          break
        fi
      else
        if aws s3api create-bucket \
            --bucket "$bucket_name" \
            --region "$REGION" \
            --create-bucket-configuration LocationConstraint="$REGION"; then
          echo "✅ Bucket '$bucket_name' created."
          success=true
          break
        fi
      fi
      echo "Failed to create bucket '$bucket_name'. Retrying..."
      sleep 2
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
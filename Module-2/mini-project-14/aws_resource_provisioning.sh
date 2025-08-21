#!/bin/bash
set -euo pipefail
trap 'echo "❌ Error on line $LINENO" >&2' ERR

# ===== Logging =====
LOGFILE="provision.log"
exec > >(tee -i "$LOGFILE") 2>&1

# ===== Input Parameters =====
ENVIRONMENT="${1:-}"
AMI_ID="${2:-}"
KEYPAIR="${3:-}"
REGION="${4:-${AWS_DEFAULT_REGION:-}}"
COUNT="${5:-}"
SUBNET_ID="${6:-}"
INSTANCE_TYPE="${7:-t2.micro}"

# ===== Validate Parameters =====
if [ $# -lt 5 ] || [ $# -gt 7 ]; then
  echo "Usage: $0 <environment> <ami_id> <keypair_name> <region> <instance_count> [subnet_id] [instance_type]"
  exit 1
fi

if [ -z "$REGION" ]; then
  echo "❌ Region not provided and AWS_DEFAULT_REGION not set."
  exit 1
fi

# ===== Environment Check =====
activate_infra_environment() {
  case "$1" in
    local|testing|production) echo "🌍 Running in $1 environment..." ;;
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

  if ! aws sts get-caller-identity --region "$REGION" >/dev/null 2>&1; then
    echo "❌ Unable to validate AWS identity. Check credentials/permissions."
    exit 1
  fi
}

# ===== Subnet Check =====
check_subnet() {
  if [ -n "$SUBNET_ID" ]; then
    if ! aws ec2 describe-subnets --subnet-ids "$SUBNET_ID" --region "$REGION" >/dev/null 2>&1; then
      echo "❌ Subnet $SUBNET_ID not found in region $REGION."
      exit 1
    fi
  fi
}

# ===== Function to Create EC2 Instances =====
create_ec2_instances() {
  echo "🔑 Checking key pair..."
  if ! aws ec2 describe-key-pairs --key-names "$KEYPAIR" --region "$REGION" >/dev/null 2>&1; then
    echo "❌ Key pair '$KEYPAIR' not found in region $REGION."
    exit 1
  fi

  echo "🚀 Launching $COUNT EC2 instance(s) of type $INSTANCE_TYPE..."

  local aws_cmd
  aws_cmd=(aws ec2 run-instances \
      --image-id "$AMI_ID" \
      --instance-type "$INSTANCE_TYPE" \
      --count "$COUNT" \
      --key-name "$KEYPAIR" \
      --region "$REGION" \
      --tag-specifications "ResourceType=instance,Tags=[{Key=Environment,Value=$ENVIRONMENT}]")

  if [ -n "$SUBNET_ID" ]; then
    aws_cmd+=(--subnet-id "$SUBNET_ID")
  fi

  instance_ids=$("${aws_cmd[@]}" --query 'Instances[*].InstanceId' --output text)
  echo "✅ Created instances: $instance_ids"
}

# ===== Function to Create S3 Buckets =====
create_s3_buckets() {
  company="datawise"
  departments=("Marketing" "Sales" "HR" "Operations" "Media")
  timestamp="$(date +%s)"
  MAX_RETRIES=3

  for department in "${departments[@]}"; do
    dep_norm="$(echo "$department" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9-' '-')"
    bucket_name="${company}-${dep_norm}-${timestamp}-data-bucket"

    attempt=1
    success=false
    while [ $attempt -le $MAX_RETRIES ]; do
      echo "Attempt $attempt: Creating bucket: $bucket_name..."
      if [ "$REGION" = "us-east-1" ]; then
        if aws s3api create-bucket \
            --bucket "$bucket_name" \
            --region "$REGION"; then
          success=true
        fi
      else
        if aws s3api create-bucket \
            --bucket "$bucket_name" \
            --region "$REGION" \
            --create-bucket-configuration LocationConstraint="$REGION"; then
          success=true
        fi
      fi

      if [ "$success" = true ]; then
        echo "✅ Bucket '$bucket_name' created."
        break
      fi

      echo "⚠️ Failed to create bucket '$bucket_name'. Retrying..."
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
check_subnet
create_ec2_instances
create_s3_buckets

echo "🎯 Provisioning complete. Logs saved to $LOGFILE"

# Usage examples:
# ./aws_resource_provisioning.sh testing ami-0e95a5e2743ec9ec9 MyKey us-east-1 2 "" t2.micro

# ./aws_resource_provisioning.sh testing ami-0e95a5e2743ec9ec9 MyKey us-east-1 2 "subnet-12345678" t2.micro
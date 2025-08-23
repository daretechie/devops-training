#!/bin/bash

# Set the environment from the first argument
ENVIRONMENT=$1

# Check if an environment is provided
if [ -z "$ENVIRONMENT" ]; then
  echo "Usage: $0 <local|testing|production>"
  exit 1
fi

echo "Selected environment: $ENVIRONMENT"

# --- AWS CLI Integration ---
# This section will be filled with AWS CLI commands
# to provision resources based on the environment.

# Note: Using AMI ami-0c55b159cbfafe1f0 (Amazon Linux 2 in us-east-1). 
# You may need to change this depending on your region.

case $ENVIRONMENT in
  local) 
    echo "Running in local mode. No AWS resources will be provisioned."
    ;; 
  testing) 
    echo "Provisioning testing environment..."
    # Provision a t2.micro EC2 instance
    INSTANCE_ID=$(aws ec2 run-instances \
      --image-id ami-0c55b159cbfafe1f0 \
      --instance-type t2.micro \
      --tag-specifications 'ResourceType=instance,Tags=[{Key=Environment,Value=Testing}]' \
      --query 'Instances[0].InstanceId' \
      --output text)

    if [ $? -eq 0 ]; then
      echo "Successfully provisioned EC2 instance with ID: $INSTANCE_ID"
    else
      echo "Failed to provision EC2 instance."
      exit 1
    fi
    ;;
  production) 
    echo "Provisioning production environment..."
    # Provision a t2.small EC2 instance
    INSTANCE_ID=$(aws ec2 run-instances \
      --image-id ami-0c55b159cbfafe1f0 \
      --instance-type t2.small \
      --tag-specifications 'ResourceType=instance,Tags=[{Key=Environment,Value=Production}]' \
      --query 'Instances[0].InstanceId' \
      --output text)

    if [ $? -eq 0 ]; then
      echo "Successfully provisioned EC2 instance with ID: $INSTANCE_ID"
    else
      echo "Failed to provision EC2 instance."
      exit 1
    fi
    ;; 
  *)
    echo "Invalid environment. Please use 'local', 'testing', or 'production'."
    exit 1
    ;; 
esac

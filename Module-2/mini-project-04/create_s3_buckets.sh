#!/bin/bash

create_s3_buckets() {
    company="datawise"
    user=$(whoami)
    timestamp=$(date +%s)
    region="us-east-1"
    departments=("Marketing" "Sales" "HR" "Operations" "Media")

    # Check if AWS CLI is installed
    if ! command -v aws &>/dev/null; then
        echo "❌ AWS CLI is not installed. Please install it before running this script."
        exit 1
    fi

    for department in "${departments[@]}"; do
        bucket_name="${company,,}-${department,,}-${user,,}-${timestamp}"

        echo "🔍 Checking if S3 bucket '$bucket_name' exists..."

        if aws s3api head-bucket --bucket "$bucket_name" 2>/dev/null; then
            echo "ℹ️ S3 bucket '$bucket_name' already exists."
        else
            echo "📦 Creating bucket: $bucket_name..."
            output=$(aws s3api create-bucket --bucket "$bucket_name" --region "$region" 2>&1)
            status=$?

            if [ $status -eq 0 ]; then
                echo "✅ S3 bucket '$bucket_name' created successfully."
            else
                if [[ $output == *"InvalidAccessKeyId"* ]]; then
                    echo "❌ Invalid AWS Access Key ID. Please reconfigure with: aws configure"
                elif [[ $output == *"InvalidClientTokenId"* ]]; then
                    echo "❌ AWS credentials appear to be incorrect or expired."
                elif [[ $output == *"Could not connect to the endpoint URL"* ]]; then
                    echo "❌ Network error. Please check your internet connection or AWS region."
                elif [[ $output == *"BucketAlreadyExists"* ]]; then
                    echo "❌ Bucket name is globally taken. Try rerunning the script to regenerate names."
                else
                    echo "❌ Failed to create bucket '$bucket_name'."
                    echo "🔎 AWS CLI error: $output"
                fi
            fi
        fi

        echo "---------------------------------------"
    done
}

create_s3_buckets

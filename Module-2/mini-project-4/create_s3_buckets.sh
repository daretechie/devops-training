#!/bin/bash

create_s3_buckets() {
    company="datawise"
    user=$(whoami)  # get your system username
    timestamp=$(date +%s)
    departments=("Marketing" "Sales" "HR" "Operations" "Media")

    for department in "${departments[@]}"; do
        bucket_name="${company,,}-${department,,}-${user,,}-${timestamp}"

        # Check if bucket already exists
        if aws s3api head-bucket --bucket "$bucket_name" 2>/dev/null; then
            echo "S3 bucket '$bucket_name' already exists."
        else
            aws s3api create-bucket --bucket "$bucket_name" --region us-east-1
            if [ $? -eq 0 ]; then
                echo "✅ S3 bucket '$bucket_name' created successfully."
            else
                echo "❌ Failed to create bucket '$bucket_name'. Please check your AWS CLI config or permissions."
            fi
        fi
    done
}

create_s3_buckets

#!/bin/bash

# Automated Script for Creating an S3 Bucket
BUCKET_NAME=$1
REGION=${2:-us-east-1}

if [ -z "$BUCKET_NAME" ]; then
    echo "Usage: $0 <bucket-name> [region]"
    exit 1
fi

echo "Creating S3 bucket: $BUCKET_NAME in region: $REGION"

# Create bucket
aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION" \
    --object-ownership BucketOwnerEnforced \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

if [ $? -eq 0 ]; then
    echo "✅ Bucket created successfully: $BUCKET_NAME"
else
    echo "❌ Failed to create bucket: $BUCKET_NAME"
    exit 1
fi
```

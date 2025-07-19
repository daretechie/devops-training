#!/bin/bash
# bulk-upload.sh

BUCKET_NAME=$1
SOURCE_DIR=$2
TARGET_PREFIX=${3:-""}

if [ -z "$BUCKET_NAME" ] || [ -z "$SOURCE_DIR" ]; then
    echo "Usage: $0 <bucket-name> <source-directory> [target-prefix]"
    exit 1
fi

echo "Uploading files from $SOURCE_DIR to s3://$BUCKET_NAME/$TARGET_PREFIX"

# Sync with progress and exclude certain files
aws s3 sync "$SOURCE_DIR" "s3://$BUCKET_NAME/$TARGET_PREFIX" \
    --exclude "*.tmp" \
    --exclude "*.log" \
    --exclude ".DS_Store" \
    --delete \
    --progress

if [ $? -eq 0 ]; then
    echo "✅ Upload completed successfully"

    # Display upload summary
    echo "📊 Upload Summary:"
    aws s3 ls "s3://$BUCKET_NAME/$TARGET_PREFIX" --recursive --human-readable --summarize
else
    echo "❌ Upload failed"
    exit 1
fi

#!/bin/bash
# manage-versions.sh

BUCKET_NAME=$1
ACTION=$2

if [ -z "$BUCKET_NAME" ] || [ -z "$ACTION" ]; then
    echo "Usage: $0 <bucket-name> <enable|disable|status|cleanup>"
    exit 1
fi

case $ACTION in
    "enable")
        echo "Enabling versioning for bucket: $BUCKET_NAME"
        aws s3api put-bucket-versioning \
            --bucket "$BUCKET_NAME" \
            --versioning-configuration Status=Enabled
        echo "✅ Versioning enabled"
        ;;
    "disable")
        echo "Suspending versioning for bucket: $BUCKET_NAME"
        aws s3api put-bucket-versioning \
            --bucket "$BUCKET_NAME" \
            --versioning-configuration Status=Suspended
        echo "⚠️ Versioning suspended"
        ;;
    "status")
        echo "Checking versioning status for bucket: $BUCKET_NAME"
        aws s3api get-bucket-versioning --bucket "$BUCKET_NAME"
        ;;
    "cleanup")
        echo "Cleaning up old versions (keeping latest 5 versions per object)"
        aws s3api list-object-versions --bucket "$BUCKET_NAME" \
            --query 'Versions[?IsLatest==`false`].[Key,VersionId]' \
            --output text | \
        while read key version_id; do
            # Count versions for this key
            version_count=$(aws s3api list-object-versions --bucket "$BUCKET_NAME" \
                --prefix "$key" --query 'length(Versions[])' --output text)

            if [ "$version_count" -gt 5 ]; then
                echo "Deleting old version: $key ($version_id)"
                aws s3api delete-object --bucket "$BUCKET_NAME" \
                    --key "$key" --version-id "$version_id"
            fi
        done
        echo "✅ Cleanup completed"
        ;;
    *)
        echo "Invalid action. Use: enable|disable|status|cleanup"
        exit 1
        ;;
esac
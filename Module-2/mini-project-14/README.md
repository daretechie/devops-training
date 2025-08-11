# 🚀 Mini Project – Creating AWS Resources with Functions & Arrays

Automating AWS resource creation with functions and arrays makes infrastructure provisioning faster, repeatable, and error-free.

---

## 🖥️ Function to Provision EC2 Instances

### Example Function:

```bash
#!/bin/bash

create_ec2_instances() {
    instance_type="t2.micro"
    ami_id="ami-0cd59ecaf368e5ccf"
    count=2
    region="eu-west-2"

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

📷 _\[Insert screenshot: EC2 instances launched in AWS console]_

---

## 📦 Function to Create Multiple S3 Buckets Using Arrays

### Example Function:

```bash
create_s3_buckets() {
    company="datawise"
    departments=("Marketing" "Sales" "HR" "Operations" "Media")

    for department in "${departments[@]}"; do
        bucket_name="${company}-${department}-data-bucket"
        aws s3api create-bucket --bucket "$bucket_name" --region eu-west-2
        if [ $? -eq 0 ]; then
            echo "Bucket '$bucket_name' created successfully."
        else
            echo "Failed to create bucket '$bucket_name'."
        fi
    done
}

create_s3_buckets
```

📷 _\[Insert screenshot: S3 bucket list in AWS console]_

---

## 🛠️ Troubleshooting Tips

| Problem                      | Cause                                   | Solution                                             |
| ---------------------------- | --------------------------------------- | ---------------------------------------------------- |
| `InvalidKeyPair.NotFound`    | Key pair not created in AWS             | Create key pair in AWS console before running script |
| `RequestLimitExceeded`       | API call limit reached                  | Wait and retry, or space out creation commands       |
| `BucketAlreadyExists`        | S3 bucket names must be globally unique | Use a unique prefix/suffix in bucket names           |
| `AWS CLI is not installed`   | CLI not available on the system         | Install via `sudo apt install awscli`                |
| `AWS profile not configured` | No credentials set                      | Run `aws configure` to set access key and secret     |

📷 _\[Insert screenshot: aws configure setup]_

---

## 💡 Key Concepts

- **Functions**: Encapsulate commands for reusability.
- **Arrays**: Store multiple values and iterate over them with loops.
- **\$?**: Checks the exit status of the last command.
- **Global Uniqueness in S3**: All S3 bucket names must be globally unique.

---

## 🏁 Conclusion

Using AWS CLI with functions and arrays allows quick provisioning of multiple resources with minimal manual effort. This approach ensures consistent naming, reduces human error, and enables easy scaling of infrastructure. With EC2 provisioning and S3 bucket creation automated, the workflow is efficient and ready for production-level usage.

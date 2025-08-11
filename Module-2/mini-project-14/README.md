## DevOps Project README

### Project Summary

This project provides a basic introduction to creating AWS resources using shell scripting, focusing on two key services: EC2 and S3. You'll learn to write functions to provision EC2 instances and create S3 buckets, leveraging the AWS CLI and basic shell scripting concepts like arrays and loops.

---

### Prerequisites

Before you begin, ensure you have the following installed and configured:

- **AWS CLI:** The command-line interface for managing AWS services.
- **AWS credentials:** Your AWS access keys must be configured to allow the CLI to interact with your account.
- **A Key Pair:** You must create an EC2 key pair in your desired region from the AWS console. The script will reference this key pair.

---

### Project Breakdown

#### 1\. Functions to Provision AWS Resources

The project is built around two main functions: `create_ec2_instances()` and `create_s3_buckets()`.

##### **`create_ec2_instances()`**

This function provisions EC2 instances using the `aws ec2 run-instances` command.

**Usage:**

```bash
aws ec2 run-instances \
    --image-id "ami-0cd59ecaf368e5ccf" \
    --instance-type "t2.micro" \
    --count 5 \
    --key-name MyKeyPair \
    --region eu-west-2
```

- **`$?:`** This special variable captures the exit status of the previous command. A value of `0` indicates success. We use this to check if the `aws ec2 run-instances` command was successful.

##### **`create_s3_buckets()`**

This function creates multiple S3 buckets using the `aws s3api create-bucket` command. It introduces the use of arrays to manage a list of bucket names efficiently.

**Arrays in Shell Scripting:**
An array is a data structure that stores a collection of values under a single variable name. This is useful for tasks that involve looping through multiple items.

**Example:**

```bash
departments=("Marketing" "Sales" "HR" "Operations" "Media")
```

This line declares an array named `departments`.

To access all elements in the array, you use `${departments[@]}`. To access a single element, you use `${departments[index]}`, remembering that indexing starts at `0`.

**Usage:**

```bash
# Loop through the array and create S3 buckets
for department in "${departments[@]}"; do
    bucket_name="${company}-${department}-Data-Bucket"
    aws s3api create-bucket --bucket "$bucket_name" --region your-region
    # ... (status check and messaging) ...
done
```

---

### Troubleshooting & Common Issues

#### **Issue 1: "A key pair with the name 'MyKeyPair' does not exist"**

This error occurs when the key pair specified in the `create_ec2_instances` function (`--key-name MyKeyPair`) does not exist in the AWS region you're targeting.

**Solution:**

- Navigate to the **EC2 dashboard** in your AWS console.
- In the navigation pane, under **Network & Security**, click **Key Pairs**.
- Click **Create key pair** and give it a name that matches the one in your script.

#### **Issue 2: "AWS CLI is not installed" or "command not found"**

The script checks for the presence of the `aws` command, and this error indicates it's missing or not in your system's `PATH`.

**Solution:**

- Follow the official AWS documentation to install the AWS CLI for your operating system.

#### **Issue 3: "Invalid environment specified"**

The script expects a command-line argument (`local`, `testing`, or `production`) to be passed when it's run.

**Solution:**

- When executing the script, provide one of the valid environment names as an argument.
  - `./your-script-name.sh local`

#### **Issue 4: "S3 bucket name must be globally unique"**

This error will occur if the S3 bucket name you are trying to create already exists in the AWS S3 namespace, as all S3 bucket names must be unique across all AWS accounts worldwide.

**Solution:**

- Change the `company` variable in the `create_s3_buckets` function to a more unique identifier. For example, add a random number or your initials to the company name.
  - `company="datawise-abc-123"`

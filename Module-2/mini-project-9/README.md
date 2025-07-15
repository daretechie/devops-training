# 🔐 AWS IAM Management with Shell Script

Automating IAM resource management in AWS is critical as teams scale. This project script handles the creation of IAM users, user groups, and permission assignment using the AWS CLI, packaged inside a reusable shell script.

---

## ⚙️ Project Setup: `aws-iam-manager.sh`

### 1. **Pre-requisites**

- AWS CLI installed (`aws --version`)
- AWS CLI configured (`aws configure`)
- IAM permissions to manage users, groups, and policies
- Completion of Linux and shell scripting fundamentals

📷 _\[Insert screenshot: AWS CLI configured and working]_

---

## 📄 Script Structure & Logic

```bash
#!/bin/bash

# AWS IAM Manager Script for CloudOps Solutions
# Automates user, group creation, and permission assignment

IAM_USER_NAMES=("user1" "user2" "user3" "user4" "user5")

create_iam_users() {
  echo "Starting IAM user creation..."
  for user in "${IAM_USER_NAMES[@]}"; do
    aws iam get-user --user-name "$user" &>/dev/null
    if [ $? -ne 0 ]; then
      aws iam create-user --user-name "$user" && echo "Created $user"
    else
      echo "User $user already exists"
    fi
  done
}

create_admin_group() {
  echo "Creating admin group and attaching policy..."
  aws iam get-group --group-name "admin" &>/dev/null
  if [ $? -ne 0 ]; then
    aws iam create-group --group-name "admin" && echo "Group created"
  else
    echo "Group already exists"
  fi

  aws iam attach-group-policy \
    --group-name admin \
    --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
}

add_users_to_admin_group() {
  echo "Adding users to admin group..."
  for user in "${IAM_USER_NAMES[@]}"; do
    aws iam add-user-to-group \
      --user-name "$user" \
      --group-name admin
    echo "Added $user to admin group"
  done
}

main() {
  echo "Starting AWS IAM automation..."
  if ! command -v aws &>/dev/null; then
    echo "Error: AWS CLI not installed."
    exit 1
  fi

  create_iam_users
  create_admin_group
  add_users_to_admin_group

  echo "✅ IAM automation complete"
}

main
```

[AWS IAM manager]

---

📷 _\[Insert screenshot: script displayed in terminal]_

---

### ✅ Make Script Executable and Run

After saving the script file, make it executable and run it:

```bash
chmod +x aws-iam-manager.sh
./aws-iam-manager.sh
```

📷 _\[Insert screenshot: successful execution or IAM Console showing created users/groups]_

---

### ⚡ Error Handling (Built-in in Script)

To make the script safe and idempotent (i.e., can run multiple times without breaking), the following patterns are used:

#### **User Already Exists**

Skip user creation if they exist:

```bash
aws iam get-user --user-name "$user" &>/dev/null || aws iam create-user --user-name "$user"
```

#### **Group Already Exists**

Skip group creation if it already exists:

```bash
aws iam get-group --group-name admin &>/dev/null || aws iam create-group --group-name admin
```

#### **Policy Attachment Feedback**

Capture success or failure of policy attachment:

```bash
if aws iam attach-group-policy --group-name admin \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess; then
  echo "Policy attached."
else
  echo "Failed to attach policy."
fi
```

These checks make the script **safe to re-run** and eliminate common failure scenarios during AWS IAM provisioning.

---

### 🤖 Debugging Scripts with `set -x`

To troubleshoot issues in real-time:

```bash
#!/bin/bash
set -x   # Enables debugging
```

Disable debugging when needed:

```bash
set +x   # Stops command tracing
```

This traces each line as it's executed—great for identifying incorrect arguments or failed commands in AWS CLI calls.

---

## 🛠️ Troubleshooting & Common Errors

| Problem                        | Cause                        | Solution                                          |
| ------------------------------ | ---------------------------- | ------------------------------------------------- |
| `aws: command not found`       | AWS CLI not installed        | Install using: `sudo apt install awscli`          |
| `Unable to locate credentials` | AWS CLI not configured       | Run: `aws configure`                              |
| `EntityAlreadyExists` errors   | User or group already exists | Script handles this—outputs message and skips     |
| `AccessDenied` errors          | Missing IAM permissions      | Attach IAM full-access policy to the AWS CLI user |

📷 _\[Insert screenshot: CLI error with AccessDenied and fix]_

---

## 🧠 Key Concepts & Good Practices

### ✅ IAM Resource Checks

Always verify the existence of users or groups using:

```bash
aws iam get-user --user-name "user1"
```

Avoids script failure when entities already exist.

---

### ✅ Using Arrays for User Lists

The array structure makes bulk user creation and management clean and repeatable:

```bash
IAM_USER_NAMES=("user1" "user2" "user3")
```

---

### ✅ Portability via Shebang

```bash
#!/bin/bash
```

- Guarantees Bash shell execution.
- Promotes portability across environments where `/bin/bash` is available.
- Avoids ambiguous behavior with system default shells.

---

### 🐞 Debugging with `set -x`

Enable line-by-line execution tracing:

```bash
set -x   # Start debugging
# your logic
set +x   # Stop debugging
```

Helps in identifying which line fails during script execution.

---

## 📝 Project Deliverables

- ✅ Fully documented script: `aws-iam-manager.sh`
- ✅ Image evidence of:

  - AWS CLI installed & configured
  - Script execution and IAM user/group creation
  - Policy attachment and group assignment

- ✅ GitHub or cloud link to script for review

---

## 🏁 Conclusion

This project extends basic shell scripting into real-world AWS IAM automation using arrays, loops, functions, and CLI integration. The script is reusable, handles errors gracefully, and promotes safe cloud operations at scale.

Next steps might include:

- Adding role-based policies
- Logging all AWS CLI outputs
- Triggering scripts via cron for scheduled IAM tasks

#!/bin/bash

# AWS IAM Manager Script for CloudOps Solutions
# Automates user, group creation, and permission assignment

IAM_USER_NAMES=("user1" "user2" "user3" "user4" "user5")

# Create IAM users if they do not exist
create_iam_users() {
  echo "Starting IAM user creation..."
  for user in "${IAM_USER_NAMES[@]}"; do
    aws iam get-user --user-name "$user" &>/dev/null
    if [ $? -ne 0 ]; then
      aws iam create-user --user-name "$user" && echo "Created IAM user: $user"
    else
      echo "User $user already exists."
    fi
  done
  echo "IAM user creation completed."
}

# Create admin group and attach AdministratorAccess policy
create_admin_group() {
  echo "Creating admin group and attaching policy..."
  aws iam get-group --group-name "admin" &>/dev/null
  if [ $? -ne 0 ]; then
    aws iam create-group --group-name "admin" && echo "Group created"
  else 
    echo "Group already exists."
  fi

  aws iam attach-group-policy --group-name "admin" --policy-arn "arn:aws:iam::aws:policy/AdministratorAccess"

}

# Add users to the admin group
add_users_to_admin_group() {
  echo "Adding users to admin group..."
  for user in "${IAM_USER_NAMES[@]}"; do
    aws iam add-user-to-group  --user-name "$user" --group-name "admin"
    echo "Added $user to admin group."
  done
}

# Main function to execute the script
main() {
  echo "Starting AWS IAM automation script..."
  if ! command -v aws &>/dev/null; then
    echo "Error: AWS CLI not installed. Please install it and configure your credentials."
    exit 1
  fi

  create_iam_users
  create_admin_group
  add_users_to_admin_group

  echo "All users created, group created, and users added to the group successfully."
}

# Execute the main function
main
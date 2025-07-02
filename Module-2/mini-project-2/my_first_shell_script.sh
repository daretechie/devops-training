#!/bin/bash

# This script creates folders and users
# Useful for onboarding new employees
# Only run this with sudo privileges
# Create directories
mkdir Folder1
mkdir Folder2
mkdir Folder3

# Create users
sudo useradd user1
sudo useradd user2
sudo useradd user3

# This is a single-line comment
echo "Welcome to Shell Scripting!" # Inline comment
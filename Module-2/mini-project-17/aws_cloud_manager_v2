#!/bin/bash

# AWS Cloud Manager Script - Complete Implementation
# This script demonstrates environment variables and positional parameters

# Step 1: Check if exactly one argument is provided

# Step 1: Check if exactly one argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <environment>"
    echo "Available environments: local, testing, production"
    exit 1
fi

# Step 2: Capture the environment argument
ENVIRONMENT=$1

# Step 3: Define environment-specific variables
case "$ENVIRONMENT" in 
"local")
    echo "=== Running script for Local Environment ==="
    # Local development environment variables
    DB_URL="localhost"
    DB_USER="test_user"
    DB_PASS="test_pass"
    AWS_REGION="us-east-1"
    INSTANCE_TYPE="t2.micro"
    echo "Database URL: $DB_URL"
    echo "Database User: $DB_USER"
    echo "AWS Region: $AWS_REGION"
    echo "Instance Type: $INSTANCE_TYPE"
    # Commands for local environment would go here
    echo "Local development commands would execute here..."
    ;;
  "testing")
    echo "=== Running script for Testing Environment ==="
    # Testing environment variables (AWS Account 1)
    DB_URL="testing-db.example.com"
    DB_USER="testing_user"
    DB_PASS="testing_pass"
    AWS_REGION="us-west-2"
    INSTANCE_TYPE="t3.small"
    echo "Database URL: $DB_URL"
    echo "Database User: $DB_USER"
    echo "AWS Region: $AWS_REGION"
    echo "Instance Type: $INSTANCE_TYPE"
    # Commands for testing environment would go here
    echo "Testing environment commands would execute here..."
    ;;
  "production")
    echo "=== Running script for Production Environment ==="
    # Production environment variables (AWS Account 2)
    DB_URL="production-db.example.com"
    DB_USER="prod_user"
    DB_PASS="prod_pass"
    AWS_REGION="us-east-1"
    INSTANCE_TYPE="t3.medium"
    echo "Database URL: $DB_URL"
    echo "Database User: $DB_USER"
    echo "AWS Region: $AWS_REGION"
    echo "Instance Type: $INSTANCE_TYPE"
    # Commands for production environment would go here
    echo "Production environment commands would execute here..."
    ;;
  *)
    echo "Invalid environment specified: $ENVIRONMENT"
    echo "Please use 'local', 'testing', or 'production'."
    exit 2
    ;;
esac

echo "Script execution completed for $ENVIRONMENT environment."
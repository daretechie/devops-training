#!/bin/bash

# ENVIRONMENT passed as an argument
ENVIRONMENT=$1

# Function to check if argument is passed
check_num_of_args() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: $0 <environment>"
        exit 1
    fi
}

# Function to activate environment-specific logic
activate_infra_env() {
    if [ "$ENVIRONMENT" == "local" ]; then
        echo "Running script for local environment..."
    elif [ "$ENVIRONMENT" == "production" ]; then
        echo "Running script for production environment..."
    elif [ "$ENVIRONMENT" == "testing" ]; then
        echo "Running script for testing environment..."
    else
        echo "Invalid environment specified. Please use 'local', 'testing', or 'production'."
        exit 2
    fi
}

# Function to check if AWS CLI is installed
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo "AWS CLI is not installed. Please install it before proceeding."
        return 1
    fi
}

# Function to check if AWS_PROFILE is set
check_aws_profile() {
    if [ -z "$AWS_PROFILE" ]; then
        echo "AWS_PROFILE is not set. Please set it before running this script."
        return 1
    fi
}

# Function Calls
check_num_of_args "$@"
activate_infra_env
check_aws_cli
check_aws_profile
#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <environment>"
    exit 1
fi

ENVIRONMENT=$1

# Checking and acting on the environment variable
if [ "$ENVIRONMENT" == "local" ]; then
  echo "Running script for Local Environment..."
  # Commands for local environment
elif [ "$ENVIRONMENT" == "testing" ]; then
    echo "Running script for Testing Environment..."
    # Commands for testing environment  
elif [ "$ENVIRONMENT" == "production" ]; then
    echo "Running script for Production Environment..."
    # Commands for production environment
else
    echo "Invalid environment specified. Please use 'local', 'testing', or 'production'."
    exit 2
fi
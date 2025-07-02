#!/bin/bash

# ---------------------------------------------
# This script demonstrates how to use comments
# and basic Bash scripting functionality.
# It prints welcome and goodbye messages,
# creates a folder, and lists contents.
# ---------------------------------------------

# Print a welcome message
echo "Welcome to the Bash Scripting Tutorial!"  # Inline comment

# Create a test directory if it doesn't exist
[ ! -d "TestFolder" ] && mkdir TestFolder

# List files and folders in the current directory
echo "Listing current directory contents:"
ls -lah

# Goodbye message
echo "Script execution complete. Goodbye!"
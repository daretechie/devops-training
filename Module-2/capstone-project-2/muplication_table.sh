#!/bin/bash

# Prompt the user 
read -p "Enter a number to generate its multiplication table: " number
number=$(echo "$number" | xargs)  # Trim whitespace

while [[ ! "$number" =~ ^[0-9]+$ ]]; do
    echo -e "Invalid input. Please enter a valid number.\n"
    read -p "Enter a number to generate its multiplication table: " number
    number=$(echo "$number" | xargs)  # Trim whitespace
done

# Table type
read -p "Do you want a full table or a partial table? (Enter 'f' for full, 'p' for partial): " table_type
while [[ ! "$table_type" =~ ^[fp]$ ]]; do
    echo -e "Invalid input. Enter 'f' for full or 'p' for partial.\n"
    read -p "Do you want a full table or a partial table? (Enter 'f' for full, 'p' for partial): " table_type
done

# Start and end only required for partial
if [[ "$table_type" == "p" ]]; then
    read -p "Enter the starting number (between 1 and 10): " start_number
    read -p "Enter the ending number (between 1 and 10): " end_number

    # Validate start and end numbers
    while [[ ! "$start_number" =~ ^[1-9][0-9]*$ || ! "$end_number" =~ ^[1-9][0-9]*$ || "$start_number" -gt "$end_number" ]]; do
        echo -e "Invalid input. Please enter valid start and end numbers.\n"
        read -p "Enter the starting number (between 1 and 10): " start_number
        read -p "Enter the ending number (between 1 and 10): " end_number
    done
fi

# Ask for order
read -p "Do you want to display in ascending or descending order? (Enter 'a' for ascending, 'd' for descending): " order_type

# Validate order type
while [[ ! "$order_type" =~ ^[ad]$ ]]; do
    echo -e "Invalid input. Please enter 'a' for ascending or 'd' for descending.\n"
    read -p "Do you want to display in ascending or descending order? (Enter 'a' for ascending, 'd' for descending): " order_type
done

#####################
#Part One: List-Form#
#####################
# Generate table using list-form loops only
echo -e "\nMultiplication Table using List-Form"
if [[ "$table_type" == "f" ]]; then
    echo -e "Full Multiplication Table for $number:"
    if [[ "$order_type" == "a" ]]; then
        for i in {1..10}; do
            product_number=$((i*number))
            echo "$number * $i = $product_number"
        done
    else
        for i in $(seq 10 -1 1); do
            product_number=$((i*number))
            echo "$number * $i = $product_number"
        done
    fi
else
    echo -e "\nPartial Multiplication Table for $number from $start_number to $end_number:\n"
    if [[ "$order_type" == "a"  ]]; then
        for i in $(seq $start_number $end_number); do
            product_number=$((i*number))
            echo "$number * $i = $product_number"
        done
    else
        for i in $(seq $end_number -1 $start_number); do
            product_number=$((i*number))
            echo "$number * $i = $product_number"
        done
    fi
fi

#######################
# Part Two: C-Style   #
#######################
# Generate table using C-style loops only
echo -e "\nMultiplication Table using C-Style"
if [[ "$table_type" == "f" ]]; then
    echo -e "Full Multiplication Table for $number:"
    if [[ "$order_type" == "a" ]]; then
        for ((i=1; i<=10; i++)); do
            product_number=$((i*number))
            echo "$number * $i = $product_number"
        done
    else
        for ((i=10; i>=1; i--)); do
            echo "$number * $i = $((number * i))"
        done
    fi
else
    echo -e "\nPartial Multiplication Table for $number from $start_number to $end_number:\n"
    if [[ "$order_type" == "a" ]]; then
        for ((i=start_number; i<=end_number; i++)); do
            echo "$number * $i = $((number * i))"
        done
    else
        for ((i=end_number; i>=start_number; i--)); do
            echo "$number * $i = $((number * i))"
        done
    fi
fi

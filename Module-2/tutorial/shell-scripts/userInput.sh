#! /bin/bash

# Taking one arg from user
echo "Enter name : "
read name
echo "Entered Name: $name"
echo

# Taking more tha one arg from user
echo "Enter name : "
read name1 name2 name2
echo "Entered Name: $name1, $name2, $name3"
echo

# user input to be on the same line
read -p "username : " user_val
# hidden paaword
read -sp "password : " pass_var
echo
echo "username : $user_val" 
echo "password : $pass_var" 
echo

# user can enter more than one value
echo "Enter several names : "
read -a names
echo "Names : ${names[0]}, ${names[1]}"
echo

# When we don't specify the variable name
echo "Enter name : "
read
echo "Name : $REPLY"
#! /bin/bash

#if [condition ]
#then
#  statement
#fi


: 'count=10
if (($count == 10))
then 
  echo "condition is true"
fi

word="abcbc"

if [ $word = "abcc" ]
then 
  echo "condition abc is true"
elif [ $word = "abcbc" ]
then
  echo "word is abcbc"
else
  echo "condition is false"
fi
'

# if a number is positive, negative, or zero.
read -p "Enter a number: " num

if [ "$num" -gt 0 ]; then
  echo "Positive"
elif [ "$num" -lt 0 ]; then
  echo "Negative"
else
  echo "Zero"
fi

# person is eligible to vote (18 years and above)
read -p "Enter your age: " age

if [ "$age" -ge 18 ]; then
  echo "You are eligible to vote."
else
  echo "You are not eligible to vote."
fi

# checks if the user's name is "admin".
read -p "Enter your username: " user

if [ "$user" = "admin"]; then
  echo "Welcome, admin!"
else
  echo "Access denied."
fi

# check if a string is empty.
read -p "Enter something: " input

if [ -z "$input" ]; then
  echo "You entered an empty string."
else
  echo "You entered: $input"
fi

# check if a string is not empty.
read -p "Enter something: " input

if [ -n "$input" ]; then
  echo "You entered: $input."
else
  echo "It is empty"
fi

# checks if two strings are equal and also not empty.
read -p "Enter first string: " str1
read -p "Enter second string: " str2

if [[ -n "$str1"  &&  -n "$str2" && "$str1" = "$str2" ]]; then
  echo "Strings are equal and not empty."
else
  echo "Strings are not equal or one is empty."
fi
#! /bin/bash

#if [condition ]
#then
#  statement
#fi


count=10
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
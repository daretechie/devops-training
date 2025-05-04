#! /bin/bash

# passing argument when runing the script
echo $1 $2 $3 ' > echo $1 $2 $3'


args=("$@")
echo "${args[0]} ${args[1]} ${args[2]} ${args[3]}"

echo $@ "using \$@"
echo $# "is number of arguments passed"
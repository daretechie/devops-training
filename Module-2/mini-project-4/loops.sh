#!/bin/bash

set -x

for i in 1 2 3 4 5
do
	echo "Hello, World! This is message $i"
done

# Using Range syntax
echo "This is Range style"

for i in {1..5}
do
	echo "COunting... $i"
done

# C-Style
echo "This is C programming style loop."

for (( i=0; i<5; i++)); do
	echo "Number $i"
done

set +x

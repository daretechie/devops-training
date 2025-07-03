# 🔁 Control Flow in Bash Scripts

Control flow statements are the backbone of decision-making in Bash scripts. They allow scripts to respond to conditions and iterate actions, making automation powerful and efficient.

---

## 🧠 What is Control Flow?

Control flow directs the sequence in which instructions are executed. Think of it as a roadmap guiding your script through decisions (using `if`/`else`) or repeating actions (using loops).

---

## 🧪 Basic Conditional Example

### Script: Determine if a Number is Positive, Negative, or Zero

```bash
#!/bin/bash
read -p "Enter a number: " num
echo "You have entered the number $num"

if [ $num -gt 0 ]; then
    echo "The number is positive."
elif [ $num -lt 0 ]; then
    echo "The number is negative."
else
    echo "The number is zero."
fi
```

📷 _\[Insert screenshot: running the script and input/output example]_

---

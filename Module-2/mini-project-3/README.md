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

# Input validation
if ! [[ "$num" =~ ^-?[0-9]+$ ]]; then
    echo "Invalid input. Please enter an integer."
    exit 1
fi

echo "You have entered the number $num"

if [ $num -gt 0 ]; then
    echo "The number is positive."
elif [ $num -lt 0 ]; then
    echo "The number is negative."
else
    echo "The number is zero."
fi
```

![control-flow](img/Screenshot%20from%202025-07-03%2004-46-59.png)

#### Example Output (Plaintext):

```
Enter a number: abc
Invalid input. Please enter an integer.

Enter a number: -5
You have entered the number -5
The number is negative.

Enter a number: 0
You have entered the number 0
The number is zero.
```

---

## 🛠️ Script Setup and Execution

### 1. **Create the Script**

```bash
vim control_flow.sh
```

### 2. **Make Executable**

```bash
chmod +x control_flow.sh
```

### 3. **Run Script**

```bash
./control_flow.sh
```

---

## ❗ Troubleshooting Tips

| Issue                                 | Cause                             | Solution                                          |
| ------------------------------------- | --------------------------------- | ------------------------------------------------- |
| `Permission denied`                   | Missing execute permission        | Run: `chmod +x control_flow.sh`                   |
| No output                             | `read` input not used correctly   | Ensure `echo $num` is included for feedback       |
| Numeric test error                    | Using `==` instead of `-eq`, etc. | Use `-eq`, `-gt`, `-lt`, `-ge`, `-le` for numbers |
| Script crashes with non-numeric input | Invalid input used in test        | Add input validation with regex check             |

---

## 🔄 Loops in Bash

### 🔹 For Loop: List Items

```bash
#!/bin/bash
for name in Alice Bob Charlie; do
  echo "Hello, $name!"
done
```

---

### 🔹 For Loop with Numbers (Range)

```bash
for i in {1..5}; do
  echo "Iteration $i"
done
```

### 🔹 C-style For Loop

```bash
for (( i=0; i<5; i++ )); do
  echo "Number $i"
done
```

![for-loop](img/Screenshot%20from%202025-07-03%2006-18-43.png)

---

## 🪄 Control Flow Syntax Summary

### 🔸 if / elif / else

```bash
if [ condition ]; then
  # commands
elif [ condition ]; then
  # commands
else
  # commands
fi
```

### 🔸 For Loop (List or Range)

```bash
for item in item1 item2; do
  # commands
done
```

### 🔸 C-style For Loop

```bash
for (( init; condition; increment )); do
  # commands
done
```

---

## 🧪 Debugging Control Flow Scripts

Use `set -x` to trace script execution:

```bash
#!/bin/bash
set -x
# your script here
set +x
```

This helps you see each command as it's executed, aiding troubleshooting.

![debug-script](img/Screenshot%20from%202025-07-03%2006-26-17.png)

---

## 📌 Bonus: Input Validation Tip

Add a numeric check to prevent invalid input:

```bash
if ! [[ $num =~ ^-?[0-9]+$ ]]; then
  echo "Invalid input: Not a number"
  exit 1
fi
```

---

## 🏁 Conclusion

You’ve learned how to:

- Use `if`, `elif`, and `else` to make decisions
- Use `for` loops to automate repeated tasks
- Validate user input and prevent script errors
- Write readable, executable, and traceable scripts

Control flow turns a basic script into a responsive, intelligent automation tool.

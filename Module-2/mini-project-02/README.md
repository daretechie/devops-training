# ✍️ Adding Comments in Bash Scripts (with Practical Script)

### 💬 What Are Comments?

Comments are essential in scripting. They **document our logic in project**, making scripts easier to understand, maintain, and debug.
Comments make your Bash scripts readable, maintainable, and collaborative. They allow you (and others) to understand your logic long after the script is written.
Comments are ignored by the shell interpreter, so they don't affect script execution.

---

### 💬 Comments in Bash

- In Bash, comments begin with `#`.
- Anything after `#` on a line is ignored by the interpreter.
- Useful for documenting the **why**, not just the **what**.

---

## ✅ Step-by-Step: Create `commented_script.sh`

### 1. **Create the Script File**

```bash
vim commented_script.sh
```

Paste this into the file:

```bash
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
```

![commented-script](img/Screenshot%20from%202025-07-02%2008-50-10.png)

---

### 2. **Make the Script Executable**

```bash
chmod u+x commented_script.sh
```

![executable-script](img/Screenshot%20from%202025-07-02%2008-52-43.png)

---

### 3. **Run the Script**

```bash
./commented_script.sh
```

![run-script](img/Screenshot%20from%202025-07-02%2008-53-15.png)

---

## 💬 Summary of Comment Types

### Shebang:

```bash
#!/bin/bash
```

Defines the interpreter for the script.

### Single-Line Comments:

```bash
# This is a comment
```

### Inline Comments:

```bash
echo "Hello"  # This explains the command
```

### Simulated Multi-Line Comments:

```bash
# Line 1 of comment
# Line 2 of comment
```

---

### ✅ Best Practices for Comments

| Principle       | Description                                                               |
| --------------- | ------------------------------------------------------------------------- |
| Clarity         | Explain **why** a block of code exists, not just _what_ it does.          |
| Maintainability | Update comments as logic changes                                          |
| Usefulness      | Focus on complex or counterintuitive logic, not obvious lines             |
| Avoid Noise     | Don't overcomment obvious or self-explanatory lines                       |
| Consistency     | Use the same style throughout your script                                 |
| Documentation   | Consider using a header comment for script purpose and usage instructions |

---

### ⚠️ Common Mistakes & Troubleshooting

| Mistake                             | Explanation                               | Fix                                              |
| ----------------------------------- | ----------------------------------------- | ------------------------------------------------ |
| Using `//` or `/* */`               | Those are not valid in Bash               | Use `#` instead                                  |
| Commenting in the wrong place       | May break code or cause unexpected output | Always place comments outside commands           |
| Forgetting to comment complex logic | Others may not understand intent          | Add summary before tricky blocks                 |
| `Permission denied` when running    | Missing execute permission                | Run: `chmod u+x commented_script.sh`             |
| `vim: command not found`            | Vim not installed                         | Run: `sudo apt install vim`                      |
| `TestFolder` not created            | Directory already exists                  | Use: `[ ! -d "TestFolder" ] && mkdir TestFolder` |

---

### 💡 Pro Tip

To temporarily disable a line of code during testing, comment it out:

```bash
# rm -rf /important-folder
```

This is safer than deleting the line and potentially forgetting it later.

---

### 🔄 Bash vs Shell – Why It Matters for Comments

While Bash and sh (Shell) are similar, always verify which shell your script runs under. Comment syntax is consistent (`#`) across both, but behaviors around things like variables or control flows can differ.

![bash-vs-shell](img/Screenshot%20from%202025-07-02%2008-21-01.png)

---

## 🏁 Conclusion

Mastering comments means writing scripts that both you and others can easily understand—today and in the future. As your projects grow in complexity, effective commenting will become one of your most valuable skills.

- In this task, we’ve learned how to:
- Write functional Bash scripts with clear documentation
- Use shebangs to define interpreters for portability
- Add single-line, inline, and multi-line comments effectively
- Perform basic scripting tasks like creating directories and printing messages
- Handle common permission issues and errors

With these skills, we're now equipped to write clean, maintainable Bash scripts that communicate both logic and intent.

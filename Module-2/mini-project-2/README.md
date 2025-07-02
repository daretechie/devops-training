# ✍️ Adding Comments in Bash Scripts

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

### 🧵 Single-Line Comments

```bash
# This is a single-line comment
echo "Welcome to Shell Scripting!" # Inline comment
```

## ![single-line-comment](img/Screenshot%20from%202025-07-02%2008-19-12.png)

### 🧱 Multiple Single-Line Comments (For Multi-line Thoughts)

```bash
# This script creates folders and users
# Useful for onboarding new employees
# Only run this with sudo privileges
```

![multi-line-comment](img/Screenshot%20from%202025-07-02%2008-21-01.png)

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

| Mistake                             | Explanation                               | Fix                                    |
| ----------------------------------- | ----------------------------------------- | -------------------------------------- |
| Using `//` or `/* */`               | Those are not valid in Bash               | Use `#` instead                        |
| Commenting in the wrong place       | May break code or cause unexpected output | Always place comments outside commands |
| Forgetting to comment complex logic | Others may not understand intent          | Add summary before tricky blocks       |

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

### ✅ You're Ready!

Mastering comments means writing scripts others (and future-you) can read with confidence. As you head into larger projects, effective commenting will become one of your most valuable skills.

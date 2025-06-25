# Linux Commands Deep Dive

This guide explores foundational Linux commands that every DevOps engineer or server administrator must master. It walks through syntax, usage, examples, and a practical mini-task.

## What is a Linux Command?

A **Linux command** is a program or utility that runs in the **command-line interface (CLI)**. These commands allow you to manage files, users, permissions, packages, and system configurations.

### General Command Syntax:

```sh
CommandName [option(s)] [parameter(s)]
```

- **CommandName**: the action to perform, e.g. `ls`, `mkdir`
- **Option/Flag**: modifies behavior, e.g. `-l`, `--help`
- **Parameter/Argument**: input for the command, e.g. file or directory names

## Basic File and Directory Management Commands

### 1. `ls` — List Files

```sh
ls
ls -l     # long format
ls -a     # show hidden files
ls -lh    # human-readable size
```

![Listing Files Example](img/img1.png)

### 2. `pwd` — Print Working Directory

```sh
pwd
```

![Current Directory Output](img/img3.png)

### 3. `cd` — Change Directory

```sh
cd /usr
cd ..     # go up one directory
cd ~      # go to home directory
```

### 4. `mkdir` — Create Directory

```sh
mkdir photos
```

![Create Directory Example](img/img2.png)

## The `sudo` Command

Some actions require **root (admin)** privileges. Use `sudo` to temporarily gain elevated rights.

### Example: Creating a folder in a protected directory

```sh
mkdir /root/example      # Fails
sudo mkdir /root/example # Succeeds
```

![Sudo Folder Creation](img/img2.png)

## Side Hustle Task)

### View contents with sudo:

```sh
sudo ls /root
```

![Sudo List Root](img/img2.png)

## Exploring the Linux Filesystem

### Root `/` contains:

- `/bin` — Essential commands like `ls`, `cp`
- `/etc` — Configuration files
- `/home` — User folders
- `/root` — Root user’s home
- `/usr` — User programs/utilities
- `/var` — Logs and variable data

Use `ls` and `cd` to explore.

```sh
sudo cd /
pwd
sudo ls -l
```

![Root Directory View](img/img4.png)

## Side Hustle Task 1 ✅

```sh
sudo mkdir /usr/photos
cd /usr/photos
mkdir fold1 fold2 fold3
ls
cd fold1
pwd
```

![Side Hustle Task Output](img/img2.png)

## Useful File Handling Commands

### 1. `cat` — View File Contents

```sh
sudo cat /etc/os-release
```

![Cat Command Output](img/img2.png)

### 2. `cp` — Copy Files & Directories

```sh
cp file.txt /home/ubuntu/Documents
cp file1.txt file2.txt /home/ubuntu
cp -R folder1 folder2
```

### 3. `mv` — Move or Rename

```sh
mv file.txt /home/ubuntu
mv old.txt new.txt
```

### 4. `rm` — Delete Files/Directories

```sh
rm file.txt
rm file1 file2
rm -r folder/
rm -f force.txt
```

### 5. `touch` — Create Empty Files

```sh
touch /home/ubuntu/Documents/Web.html
```

![Touch Command Example](img/img6.png)

### 6. `find` — Search for Files

```sh
find /home -name notes.txt
```

![Find Command Output](img/img5.png)

## Final Tips

- Commands are **case-sensitive**.
- Use `man command` to learn more about any command.
- Use `history` to view previous commands.

Stay safe with `sudo` and practice consistently!

# 🚀 Mini Project 6: Setting up Ansible on a Linux Server

## 🎯 Project Overview

**Ansible** is a powerful automation tool that simplifies IT infrastructure management. This project guides you through installing and configuring Ansible on a Linux server, enabling you to automate tasks and manage servers effectively.

In this hands-on project, you'll learn to:
- Install and configure Ansible on a control node
- Set up secure SSH key-based authentication
- Create and manage Ansible inventory files
- Test connectivity and run basic commands
- Understand the fundamentals of infrastructure automation

This project forms the foundation for more advanced Ansible topics like playbooks, roles, and complex infrastructure management.

![Ansible Architecture Overview](./img/ansible-architecture.png)

---

## 📋 Prerequisites

### Technical Requirements
- **Control Node**: A Linux server or virtual machine (Ubuntu/Debian preferred)
- **Target Node(s)**: At least one additional Linux server/VM to manage
- **SSH Access**: Ability to connect to target nodes via SSH
- **User Privileges**: Sudo access on the control node
- **Network Connectivity**: Both nodes must be able to communicate

### Required Knowledge
- Basic Linux command line skills
- Understanding of SSH connections
- Text editor familiarity (nano, vim, etc.)

### Project Deliverables for Submission
1. **Screenshots** of each major step
2. **Command outputs** showing successful execution
3. **Inventory file** configuration
4. **Ad-hoc command results** demonstrating functionality
5. **Troubleshooting evidence** (if issues occurred)

---

## 🛠️ Step-by-Step Implementation Guide

### Phase 1: Environment Preparation

#### Step 1: Verify Prerequisites

**Objective**: Ensure your system is ready for Ansible installation.

1. **Check Linux Distribution**:
```bash
cat /etc/os-release
```
*Expected Output*: Should show Ubuntu, Debian, or similar Linux distribution.

2. **Verify Sudo Access**:
```bash
sudo whoami
```
*Expected Output*: Should return `root` (confirming sudo privileges).

3. **Check Network Connectivity**:
```bash
ping -c 3 google.com
```
*Expected Output*: Successful ping responses.

![Prerequisites Verification](./img/prereq-verification.png)

---

### Phase 2: Ansible Installation

#### Step 2: Update Package Repository

**Objective**: Ensure your system has the latest package information.

```bash
sudo apt update
```

**What this does:**
- Updates the local package index
- Retrieves information about available packages
- Shows download progress and any errors

*Expected Output*: List of packages that can be upgraded.

![Package Update](./img/apt-update.png)

#### Step 3: Install Ansible

**Objective**: Install Ansible on the control node.

```bash
sudo apt install ansible -y
```

**Command breakdown:**
- `sudo`: Run with administrative privileges
- `apt install`: Package installation command
- `ansible`: The package name
- `-y`: Automatic "yes" to prompts

*Expected Output*:
```
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following NEW packages will be installed:
  ansible
0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.
Need to get 5,023 kB of archives.
After this operation, 8,214 kB of additional disk space will be used.
```

#### Step 4: Verify Installation

**Objective**: Confirm Ansible is properly installed.

```bash
ansible --version
```

*Expected Output*:
```
ansible [core 2.13.0]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/user/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /home/user/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.10.4 (main, Apr  2 2022, 09:04:19) [GCC 9.4.0]
```

![Ansible Version Check](./img/ansible-version.png)

---

### Phase 3: SSH Configuration

#### Step 5: Generate SSH Key Pair

**Objective**: Create SSH keys for passwordless authentication.

```bash
ssh-keygen -t rsa
```

**What to expect:**
1. System will prompt: `Enter file in which to save the key (/home/username/.ssh/id_rsa):`
2. **Press Enter** to accept the default location
3. System will prompt: `Enter passphrase (empty for no passphrase):`
4. **Press Enter** twice (for no passphrase - easier for automation)

*Expected Output*:
```
Generating public/private rsa key pair.
Enter file in which to save the key (/home/username/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/username/.ssh/id_rsa
Your public key has been saved in /home/username/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:ABC123...xyz789 username@hostname
The key's randomart image is:
+---[RSA 3072]----+
|    .oo.         |
|   . o.o         |
|    o o .        |
|     + .         |
|    . o S        |
|     o + .       |
|      o          |
|     E           |
|                 |
+----[SHA256]-----+
```

#### Step 6: Copy Public Key to Target Node

**Objective**: Enable passwordless SSH access to target machines.

```bash
ssh-copy-id username@target-server-ip
```

**Command explanation:**
- `ssh-copy-id`: Securely copies your public key to the target server
- `username`: Your username on the target server
- `target-server-ip`: IP address or hostname of target server

**What happens:**
1. You'll be prompted for the target server's password
2. The public key gets added to `~/.ssh/authorized_keys` on target
3. Future connections won't require passwords

*Expected Output*:
```
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/username/.ssh/id_rsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
username@target-server-ip's password:

Number of key(s) added: 1
```

#### Step 7: Test SSH Connection

**Objective**: Verify passwordless SSH works.

```bash
ssh username@target-server-ip
```

**What to expect:**
- Should connect without prompting for password
- You'll see a welcome message or shell prompt
- Type `exit` to return to control node

*Expected Output*: Direct login to target server without password prompt.

![SSH Key Setup](./img/ssh-key-setup.png)

---

### Phase 4: Ansible Configuration

#### Step 8: Create Ansible Directory

**Objective**: Organize your Ansible configuration files.

```bash
mkdir ~/ansible
cd ~/ansible
```

**What this does:**
- Creates a dedicated directory for Ansible files
- Changes to that directory for easier file management

#### Step 9: Create Inventory File

**Objective**: Define which servers Ansible should manage.

```bash
nano inventory.ini
```

**Add the following content:**
```ini
[linux_servers]
target1 ansible_host=TARGET_IP_ADDRESS ansible_user=YOUR_USERNAME
target2 ansible_host=TARGET_IP_ADDRESS ansible_user=YOUR_USERNAME

[webservers]
target1

[databases]
target2
```

**File explanation:**
- `[linux_servers]`: Group name for all managed servers
- `ansible_host`: IP address of the target server
- `ansible_user`: Username for SSH connections
- Additional groups (`[webservers]`, `[databases]`) for organization

**Save the file**: Press `Ctrl+O`, Enter, then `Ctrl+X`

![Inventory File Creation](./img/inventory-file.png)

---

### Phase 5: Testing and Verification

#### Step 10: Test Ansible Connectivity

**Objective**: Verify Ansible can communicate with target nodes.

```bash
ansible -i inventory.ini linux_servers -m ping
```

**Command breakdown:**
- `-i inventory.ini`: Specify inventory file location
- `linux_servers`: Target group from inventory
- `-m ping`: Use the ping module to test connectivity

*Expected Output*:
```
target1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

**What this means:**
- `SUCCESS`: Ansible connected successfully
- `pong`: Target server responded
- `changed: false`: No changes were made to the system

#### Step 11: Run System Information Command

**Objective**: Execute a basic command across managed servers.

```bash
ansible -i inventory.ini linux_servers -m command -a "uname -a"
```

**Command explanation:**
- `-m command`: Use the command module
- `-a "uname -a"`: Arguments to pass to the module

*Expected Output*: System information for each target server.

#### Step 12: Check Disk Usage

**Objective**: Demonstrate Ansible's ability to gather system information.

```bash
ansible -i inventory.ini linux_servers -m shell -a "df -h"
```

**Command explanation:**
- `-m shell`: Use shell module (supports piping, redirection)
- `-a "df -h"`: Disk usage command with human-readable format

*Expected Output*: Disk usage information for each target server.

![Ansible Commands Execution](./img/ansible-commands.png)

#### Step 13: Test Service Status

**Objective**: Check if specific services are running.

```bash
ansible -i inventory.ini linux_servers -m systemd -a "name=ssh state=started"
```

*Expected Output*: SSH service status across all target servers.

---

## 🛠️ Troubleshooting Guide

### Common Issues and Solutions

| Problem | Symptoms | Solution |
|---------|----------|----------|
| **Permission Denied** | `ssh: Permission denied` | Check SSH key permissions (`chmod 600 ~/.ssh/id_rsa`), verify username, ensure key is in `authorized_keys` |
| **Connection Refused** | `ssh: connect to host ... Connection refused` | Check if SSH service is running on target, verify firewall settings, confirm IP address |
| **Host Key Verification Failed** | `Host key verification failed` | SSH into target manually first to accept host key, or use `StrictHostKeyChecking=no` |
| **Ansible Command Failed** | `unreachable` or `failed` | Check inventory file syntax, verify SSH connectivity, ensure Python is installed on target |
| **Sudo Access Issues** | `sudo: no tty present` | Use `ansible_become: true` in playbooks, or configure passwordless sudo |
| **Module Not Found** | `module ... not found` | Install required Python modules on target: `sudo apt install python3-pip` |

### Debugging Commands

```bash
# Test basic SSH connection
ssh -v username@target-server-ip

# Check SSH service status on target
ssh username@target-server-ip "systemctl status ssh"

# Verify Python installation on target
ssh username@target-server-ip "python3 --version"

# Test Ansible with verbose output
ansible -i inventory.ini linux_servers -m ping -vvv

# Check Ansible configuration
ansible-config view
```

### Common Error Messages

**`Failed to connect to the host via ssh:`**
- **Cause**: SSH service not running, wrong IP/username, firewall blocking
- **Solution**: Check SSH service, verify credentials, check security groups/firewall

**`Permission denied (publickey,password)`**
- **Cause**: SSH key not properly configured or wrong username
- **Solution**: Regenerate and copy SSH keys, verify username in inventory

**`pong` not received**
- **Cause**: Ansible cannot execute Python on target
- **Solution**: Install Python: `sudo apt install python3`

---

## 📸 Evidence and Screenshots for Submission

### Required Screenshots

1. **Prerequisites Verification**
   - `evidence-01-prereq-os-version.png` - OS version check
   - `evidence-02-prereq-sudo-access.png` - Sudo privileges verification
   - `evidence-03-prereq-network.png` - Network connectivity test

2. **Ansible Installation**
   - `evidence-04-ansible-install.png` - Package installation process
   - `evidence-05-ansible-version.png` - Version verification

3. **SSH Configuration**
   - `evidence-06-ssh-keygen.png` - SSH key generation
   - `evidence-07-ssh-copy-id.png` - Public key distribution
   - `evidence-08-ssh-connection.png` - Passwordless connection test

4. **Ansible Configuration**
   - `evidence-09-inventory-file.png` - Inventory file contents
   - `evidence-10-directory-structure.png` - Ansible directory structure

5. **Testing and Commands**
   - `evidence-11-ping-test.png` - Ansible ping module results
   - `evidence-12-system-info.png` - System information command
   - `evidence-13-disk-usage.png` - Disk usage command results
   - `evidence-14-service-status.png` - Service status check

### Screenshot Naming Convention
All screenshots should be saved in the `img/` directory with descriptive names:
- `evidence-XX-description.png`
- Include terminal prompts and outputs
- Ensure text is readable and commands are visible

---

## 🎓 Key Concepts Learned

### Ansible Architecture
- **Control Node**: Machine where Ansible is installed
- **Managed Nodes**: Servers configured and managed by Ansible
- **Inventory**: File defining managed hosts and groups
- **Modules**: Pre-written scripts for specific tasks
- **Ad-hoc Commands**: Single tasks executed immediately

### SSH Key Authentication
- **Public Key**: Shared with remote servers
- **Private Key**: Kept secure on control node
- **authorized_keys**: File on target containing allowed public keys

### Ansible Modules
- **ping**: Tests connectivity
- **command**: Executes single commands
- **shell**: Executes shell commands with piping/redirection
- **systemd**: Manages system services

---

## 🔧 Advanced Configuration Options

### Custom SSH Configuration
```bash
# Create SSH config for easier connections
nano ~/.ssh/config

# Add:
Host target1
    HostName TARGET_IP_ADDRESS
    User YOUR_USERNAME
    IdentityFile ~/.ssh/id_rsa

# Test with:
ansible -i inventory.ini linux_servers -m ping
```

### Ansible Configuration File
```bash
# View current Ansible configuration
ansible-config view

# Common customizations in ansible.cfg:
[defaults]
inventory = ~/ansible/inventory.ini
host_key_checking = False
remote_user = your_username
private_key_file = ~/.ssh/id_rsa
```

### Inventory File Enhancements
```ini
[linux_servers]
target1 ansible_host=192.168.1.10 ansible_user=ubuntu ansible_ssh_private_key_file=/home/user/.ssh/id_rsa
target2 ansible_host=192.168.1.11 ansible_user=ubuntu

[linux_servers:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_become=true
ansible_become_user=root
```

---

## ✅ Project Checklist

- [ ] **Prerequisites verified** (OS, sudo, network)
- [ ] **Ansible installed** and version confirmed
- [ ] **SSH keys generated** and distributed
- [ ] **Inventory file created** with target servers
- [ ] **Connectivity tested** with ping module
- [ ] **Ad-hoc commands executed** successfully
- [ ] **All screenshots captured** for evidence
- [ ] **Troubleshooting documented** (if applicable)

---

## 🚀 Next Steps

With Ansible successfully configured, you can now:

1. **Write Your First Playbook**: Create YAML files to automate complex tasks
2. **Install Software**: Use Ansible to install packages across multiple servers
3. **Configure Services**: Set up and manage web servers, databases, etc.
4. **User Management**: Automate user creation and permission management
5. **File Management**: Distribute configuration files and templates

---

## 🏆 Project Outcomes

By completing this project, you have:

✅ **Installed and configured Ansible** on a Linux server
✅ **Established secure SSH communication** with target nodes
✅ **Created a functional inventory** for server management
✅ **Successfully executed Ansible commands** across multiple servers
✅ **Gained practical experience** with infrastructure automation tools

**Congratulations on setting up your Ansible automation environment!** 🎉

This foundation will enable you to automate complex IT tasks, manage large-scale infrastructure, and streamline your DevOps workflows.

For questions or issues, refer to the troubleshooting section or consult the official Ansible documentation at [docs.ansible.com](https://docs.ansible.com/).
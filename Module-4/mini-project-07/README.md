# 🚀 Mini Project 7: Automate User Creation on Linux Server using Ansible

## 🎯 Project Overview

**Ansible** is a powerful automation tool that simplifies IT infrastructure management. This project guides you through creating an Ansible playbook to automate user account creation on Linux servers, enabling you to manage user accounts efficiently across multiple systems.

In this hands-on project, you'll learn to:
- Install and configure Ansible for server management
- Set up secure SSH key-based authentication
- Create and execute Ansible playbooks for user automation
- Configure user groups, home directories, and SSH access
- Verify automated user creation and test access
- Understand the fundamentals of infrastructure automation

This project builds on your Ansible foundation and demonstrates practical user management automation that can be extended for various administrative tasks.

![Ansible User Management Workflow](./img/ansible-user-management.png)

---

## 📋 Prerequisites

### Technical Requirements
- **Control Node**: A Linux server or virtual machine (Ubuntu/Debian preferred)
- **Target Node(s)**: At least one Linux server/VM to manage user accounts on
- **SSH Access**: Ability to connect to target nodes via SSH
- **User Privileges**: Sudo access on the control node
- **Network Connectivity**: Both nodes must be able to communicate
- **Ansible Installed**: Ansible installed on the control node

### Required Knowledge
- Basic Linux command line skills
- Understanding of SSH connections and user management
- Text editor familiarity (nano, vim, etc.)
- Previous completion of Ansible setup project (Mini Project 6)

### Project Deliverables for Submission
1. **Screenshots** of each major step and command outputs
2. **Ansible playbook files** (inventory and user creation playbook)
3. **Command outputs** showing successful user creation
4. **Verification evidence** of created users and SSH access
5. **Troubleshooting evidence** (if issues occurred)

---

## 🛠️ Step-by-Step Implementation Guide

### Phase 1: Environment Preparation

#### Step 1: Verify Prerequisites

**Objective**: Ensure your system is ready for Ansible automation.

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

4. **Verify Ansible Installation**:
```bash
ansible --version
```
*Expected Output*: Ansible version information (if not installed, refer to Mini Project 6).

![Prerequisites Verification](./img/prereq-verification.png)

---

### Phase 2: SSH Configuration

#### Step 2: Generate SSH Key Pair

**Objective**: Create SSH keys for passwordless authentication to target servers.

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
```

#### Step 3: Copy Public Key to Target Node

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
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
username@target-server-ip's password:

Number of key(s) added: 1
```

#### Step 4: Test SSH Connection

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

### Phase 3: Ansible Configuration

#### Step 5: Create Ansible Directory Structure

**Objective**: Organize your Ansible configuration files.

```bash
mkdir ~/ansible-user-management
cd ~/ansible-user-management
```

**What this does:**
- Creates a dedicated directory for your user management project
- Changes to that directory for easier file management

#### Step 6: Create Ansible Inventory File

**Objective**: Define which servers Ansible should manage.

```bash
nano inventory.ini
```

**Add the following content:**
```ini
[linux_servers]
target1 ansible_host=TARGET_SERVER_IP ansible_user=YOUR_USERNAME

[webservers]
target1

[databases]
target1
```

**File explanation:**
- `[linux_servers]`: Group name for all managed servers
- `ansible_host`: IP address of the target server
- `ansible_user`: Username for SSH connections (should match your SSH user)
- Additional groups (`[webservers]`, `[databases]`) for organization

**Save the file**: Press `Ctrl+O`, Enter, then `Ctrl+X`

![Inventory File Creation](./img/inventory-file.png)

---

### Phase 4: Ansible Playbook Creation

#### Step 7: Create User Creation Playbook

**Objective**: Create an Ansible playbook to automate user account creation.

```bash
nano create_users.yml
```

**Add the following playbook content:**
```yaml
- name: Automate user creation on Linux servers
  hosts: linux_servers
  become: yes
  tasks:
    - name: Create new users with home directories
      user:
        name: "{{ item.username }}"
        state: present
        shell: /bin/bash
        create_home: yes
        groups: "{{ item.groups | default('users') }}"
      with_items:
        - { username: "user1", groups: "sudo" }
        - { username: "user2", groups: "docker" }

    - name: Set up SSH authorized keys for users
      authorized_key:
        user: "{{ item.username }}"
        state: present
        key: "{{ lookup('file', item.ssh_key) }}"
      with_items:
        - { username: "user1", ssh_key: "/home/ansible/.ssh/user1.pub" }
        - { username: "user2", ssh_key: "/home/ansible/.ssh/user2.pub" }
```

**Playbook explanation:**
- `become: yes`: Run tasks with sudo privileges
- `user` module: Creates users with specified parameters
- `authorized_key` module: Sets up SSH keys for users
- `with_items`: Loop through list of users to create
- **Important**: Replace SSH key paths with actual paths to your public keys

**Save the file**: Press `Ctrl+O`, Enter, then `Ctrl+X`

![Playbook Creation](./img/playbook-creation.png)

#### Step 8: Prepare SSH Keys for Users

**Objective**: Create SSH keys for the users that will be created.

**Before running the playbook, you need to:**

1. **Generate SSH keys for each user** (on the control node):
```bash
# Generate key for user1
ssh-keygen -t rsa -f ~/.ssh/user1 -N ""

# Generate key for user2
ssh-keygen -t rsa -f ~/.ssh/user2 -N ""
```

2. **Set proper permissions**:
```bash
chmod 600 ~/.ssh/user1
chmod 600 ~/.ssh/user2
chmod 644 ~/.ssh/user1.pub
chmod 644 ~/.ssh/user2.pub
```

3. **Update playbook paths** if needed to match your key locations.

---

### Phase 5: Execution and Testing

#### Step 9: Run the User Creation Playbook

**Objective**: Execute the playbook to create users on target servers.

```bash
ansible-playbook -i inventory.ini create_users.yml
```

**Command breakdown:**
- `-i inventory.ini`: Specify inventory file location
- `create_users.yml`: Your playbook file

*Expected Output*:
```
PLAY [Automate user creation on Linux servers] ****************

TASK [Gathering Facts] ****************
ok: [target1]

TASK [Create new users with home directories] ****************
changed: [target1] => (item={u'username': u'user1', u'groups': u'sudo'})
changed: [target1] => (item={u'username': u'user2', u'groups': u'docker'})

TASK [Set up SSH authorized keys for users] ****************
changed: [target1] => (item={u'username': u'user1', u'ssh_key': u'/home/ansible/.ssh/user1.pub'})
changed: [target1] => (item={u'username': u'user2', u'ssh_key': u'/home/ansible/.ssh/user2.pub'})

PLAY RECAP ****************
target1: ok=3 changed=2 unreachable=0 failed=0
```

**What this means:**
- `ok=3`: All tasks completed successfully
- `changed=2`: Users were created/modified
- `unreachable=0/failed=0`: No connection or execution failures

#### Step 10: Verify User Creation

**Objective**: Confirm that users were created successfully on the target server.

**SSH into the target server and verify:**
```bash
# Check user accounts
cat /etc/passwd | grep -E "user1|user2"

# Verify home directories exist
ls -la /home/user1
ls -la /home/user2

# Check user groups
id user1
id user2

# Verify SSH keys are installed
cat /home/user1/.ssh/authorized_keys
cat /home/user2/.ssh/authorized_keys
```

*Expected Output*:
```
/etc/passwd entries showing user1 and user2
Home directories with proper permissions
Group memberships (sudo for user1, docker for user2)
SSH public keys in authorized_keys files
```

#### Step 11: Test User Access

**Objective**: Verify that the created users can log in successfully.

**Test SSH access for each user:**
```bash
# Test user1 access (from control node)
ssh user1@target-server-ip

# Test user2 access (from control node)
ssh user2@target-server-ip

# Verify sudo access for user1 (if applicable)
sudo whoami
```

**What to expect:**
- Should connect without password prompts
- Users should have access to their home directories
- user1 should have sudo privileges (if in sudo group)

![User Verification](./img/user-verification.png)

---

## 🛠️ Troubleshooting Guide

### Common Issues and Solutions

| Problem | Symptoms | Solution |
|---------|----------|----------|
| **Permission Denied** | `Permission denied (publickey)` | Check SSH key permissions (`chmod 600 ~/.ssh/*`), verify keys in `authorized_keys` |
| **User Creation Failed** | `FAILED` in playbook output | Check sudo privileges on target, verify playbook syntax, ensure SSH connectivity |
| **SSH Key Not Found** | `file not found` error | Verify SSH key paths in playbook, ensure keys exist and are readable |
| **Connection Refused** | `unreachable` in playbook | Check SSH service on target (`sudo systemctl status ssh`), verify IP/username |
| **Group Doesn't Exist** | `group 'docker' does not exist` | Create groups first or use existing groups (sudo, users, etc.) |
| **Home Directory Issues** | Users can't access home dirs | Check filesystem permissions, ensure /home has correct permissions |

### Debugging Commands

```bash
# Test basic SSH connection with verbose output
ssh -v username@target-server-ip

# Check SSH service status on target
ssh username@target-server-ip "sudo systemctl status ssh"

# Verify user exists on target
ssh username@target-server-ip "id user1"

# Test Ansible connectivity with verbose output
ansible -i inventory.ini linux_servers -m ping -vvv

# Check playbook syntax
ansible-playbook -i inventory.ini create_users.yml --syntax-check

# Run playbook in check mode (dry run)
ansible-playbook -i inventory.ini create_users.yml --check
```

### Common Error Messages

**`FAILED! => {"changed": false, "msg": "User ... already exists"}`**
- **Cause**: User account already exists on the target system
- **Solution**: Use `state: absent` first to remove existing users, or use different usernames

**`file not found`**
- **Cause**: SSH key file path in playbook doesn't exist
- **Solution**: Verify key file paths, generate keys if missing

**`Permission denied`**
- **Cause**: SSH keys not properly configured or insufficient permissions
- **Solution**: Check key permissions, verify authorized_keys file

---

## 📸 Evidence and Screenshots for Submission

### Required Screenshots

1. **Prerequisites Verification**
   - `evidence-01-prereq-verification.png` - OS, sudo, and Ansible checks
   - `evidence-02-network-connectivity.png` - Network connectivity test

2. **SSH Configuration**
   - `evidence-03-ssh-keygen.png` - SSH key generation output
   - `evidence-04-ssh-copy-id.png` - Public key distribution
   - `evidence-05-ssh-connection.png` - Passwordless connection test

3. **Ansible Configuration**
   - `evidence-06-inventory-file.png` - Inventory file contents
   - `evidence-07-playbook-file.png` - User creation playbook
   - `evidence-08-directory-structure.png` - Project directory structure

4. **Execution and Results**
   - `evidence-09-playbook-execution.png` - Ansible playbook execution
   - `evidence-10-user-verification.png` - User account verification
   - `evidence-11-home-directories.png` - Home directory verification
   - `evidence-12-ssh-access-test.png` - SSH access testing
   - `evidence-13-group-membership.png` - User group verification

### Screenshot Naming Convention
All screenshots should be saved in the `img/` directory with descriptive names:
- `evidence-XX-description.png`
- Include terminal prompts and outputs
- Ensure text is readable and commands are visible
- Capture both successful and failed attempts (for troubleshooting evidence)

---

## 🎓 Key Concepts Learned

### Ansible Playbook Structure
- **Play**: Defines the automation scenario (hosts, tasks, variables)
- **Tasks**: Individual actions to perform (modules with parameters)
- **Modules**: Pre-built functions for specific operations
- **Variables**: Dynamic values using `{{ }}` syntax
- **Loops**: Using `with_items` to process multiple items

### User Management Concepts
- **User Accounts**: System user creation with home directories
- **Groups**: User group membership for permissions
- **SSH Keys**: Public key authentication for secure access
- **Privileges**: Sudo access and permission management

### Ansible Best Practices
- **Idempotency**: Playbooks can run multiple times safely
- **Error Handling**: Proper error checking and validation
- **Documentation**: Clear naming and comments in playbooks
- **Organization**: Structured file and directory layout

---

## 🔧 Advanced Configuration Options

### Enhanced Playbook with Password Policies
```yaml
- name: Advanced user creation with password policies
  hosts: linux_servers
  become: yes
  tasks:
    - name: Create users with password expiration
      user:
        name: "{{ item.username }}"
        state: present
        shell: /bin/bash
        create_home: yes
        groups: "{{ item.groups }}"
        password_expire_max: 90
        password_expire_warning: 7
      with_items:
        - { username: "user1", groups: "sudo" }
        - { username: "user2", groups: "docker" }
```

### User Deletion Playbook
```yaml
- name: Remove users from system
  hosts: linux_servers
  become: yes
  tasks:
    - name: Delete users and home directories
      user:
        name: "{{ item }}"
        state: absent
        remove: yes
      with_items:
        - "user1"
        - "user2"
```

### Batch User Creation from File
```yaml
- name: Create users from CSV file
  hosts: linux_servers
  become: yes
  vars:
    users_file: "users.csv"
  tasks:
    - name: Read users from CSV
      read_csv:
        path: "{{ users_file }}"
      register: users_data

    - name: Create users from CSV data
      user:
        name: "{{ item.username }}"
        groups: "{{ item.groups }}"
      loop: "{{ users_data.list }}"
```

---

## ✅ Project Checklist

- [ ] **Prerequisites verified** (OS, sudo, network, Ansible)
- [ ] **SSH keys generated** and distributed to target servers
- [ ] **Inventory file created** with correct target server details
- [ ] **User creation playbook written** with proper YAML syntax
- [ ] **SSH keys prepared** for new users
- [ ] **Playbook executed** successfully
- [ ] **User creation verified** on target server
- [ ] **SSH access tested** for created users
- [ ] **All screenshots captured** for evidence
- [ ] **Troubleshooting documented** (if applicable)

---

## 🚀 Next Steps

With user management automation mastered, you can now:

1. **Advanced User Management**: Create playbooks for user deletion, password management, and bulk operations
2. **Service Configuration**: Automate service installation and configuration
3. **File Management**: Distribute configuration files and manage permissions
4. **System Monitoring**: Set up automated system health checks
5. **Backup Automation**: Create backup strategies for user data and configurations

---

## 🏆 Project Outcomes

By completing this project, you have:

✅ **Created an Ansible playbook** for automated user account management
✅ **Configured SSH key authentication** for secure access
✅ **Successfully executed** user creation across Linux servers
✅ **Verified automated processes** with proper testing
✅ **Gained practical experience** with Ansible automation
✅ **Documented the entire process** for submission and review

**Congratulations on mastering Ansible user management automation!** 🎉

This project demonstrates your ability to automate critical system administration tasks, making you ready for more complex infrastructure automation scenarios.

For questions or issues, refer to the troubleshooting section or consult the official Ansible documentation at [docs.ansible.com](https://docs.ansible.com/).

---

## 📚 Additional Resources

- **Ansible User Module Documentation**: [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/user_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/user_module.html)
- **Ansible Authorized Key Module**: [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/authorized_key_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/authorized_key_module.html)
- **SSH Key Management Guide**: [https://www.ssh.com/academy/ssh-keys](https://www.ssh.com/academy/ssh-keys)
- **Linux User Management**: [https://linuxize.com/post/how-to-create-users-in-linux-using-the-useradd-command/](https://linuxize.com/post/how-to-create-users-in-linux-using-the-useradd-command/)
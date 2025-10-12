# 🚀 Mini Project 9: Backup and Restore Files on a Linux Server using Ansible

## 🎯 Project Overview

**Data backup and restoration** are critical practices for ensuring data safety, business continuity, and disaster recovery in Linux server management. **Ansible** simplifies these essential tasks by providing automated, scalable, and repeatable backup solutions that eliminate manual processes and reduce human error.

In this hands-on project, you'll learn to:
- Set up automated backup strategies using Ansible
- Create compressed, timestamped backup archives
- Implement robust file restoration processes
- Manage backup retention and cleanup policies
- Understand backup best practices and data protection
- Scale backup operations across multiple servers

This project builds on your Ansible foundation and demonstrates practical data protection automation that can be extended for enterprise-grade backup solutions.

![Backup and Restore Automation Workflow](./img/backup-restore-automation.png)

---

## 📋 Prerequisites

### Technical Requirements
- **Control Node**: A Linux server or virtual machine (Ubuntu/Debian preferred)
- **Target Node(s)**: At least one Linux server/VM to back up and restore files on
- **SSH Access**: Ability to connect to target nodes via SSH
- **User Privileges**: Sudo access on both control and target nodes
- **Storage Space**: Sufficient space for backup archives on target servers
- **Ansible Installed**: Ansible installed on the control node

### Required Knowledge
- Basic Linux command line skills and file system navigation
- Understanding of SSH connections and file permissions
- Text editor familiarity (nano, vim, etc.)
- Previous completion of Ansible setup projects (Mini Projects 6-8)

### Project Deliverables for Submission
1. **Screenshots** of each major step and command outputs
2. **Ansible playbook files** (backup and restore playbooks with enhancements)
3. **Command outputs** showing successful backup and restore operations
4. **Verification evidence** of backup archives and restored files
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

5. **Check Available Storage**:
```bash
df -h
```
*Expected Output*: Shows available disk space for backup storage.

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

**Objective**: Organize your Ansible configuration files for the backup project.

```bash
mkdir ~/ansible-backup-restore
cd ~/ansible-backup-restore
```

**What this does:**
- Creates a dedicated directory for your backup and restore project
- Changes to that directory for easier file management

#### Step 6: Create Ansible Inventory File

**Objective**: Define which servers Ansible should manage for backup operations.

```bash
nano inventory.ini
```

**Add the following content:**
```ini
[linux_servers]
target1 ansible_host=TARGET_SERVER_IP ansible_user=YOUR_USERNAME

[backup_servers]
target1

[file_servers]
target1
```

**File explanation:**
- `[linux_servers]`: Primary group for all managed servers
- `ansible_host`: IP address of the target server
- `ansible_user`: Username for SSH connections (should match your SSH user)
- Additional groups (`[backup_servers]`, `[file_servers]`) for organization and flexibility

**Save the file**: Press `Ctrl+O`, Enter, then `Ctrl+X`

![Inventory File Creation](./img/inventory-file.png)

---

### Phase 4: Enhanced Backup Playbook Creation

#### Step 7: Create Comprehensive Backup Playbook

**Objective**: Create an enhanced Ansible playbook for robust file backup operations with compression and metadata.

```bash
nano backup_files.yml
```

**Add the following playbook content:**
```yaml
- name: Comprehensive file backup with compression and metadata
  hosts: backup_servers
  become: yes
  vars:
    backup_base_dir: "/backup"
    backup_timestamp: "{{ ansible_date_time.iso8601 | regex_replace('[:T]', '-') | regex_replace('\\..*', '') }}"
    files_to_backup:
      - "/etc"
      - "/home"
      - "/var/www"
      - "/var/log"
    backup_retention_days: 30

  tasks:
    - name: Create backup base directory
      file:
        path: "{{ backup_base_dir }}"
        state: directory
        mode: '0755'
        owner: root
        group: root
      tags: ['setup']

    - name: Install required packages (tar, gzip)
      apt:
        name:
          - tar
          - gzip
        state: present
        update_cache: yes
      tags: ['packages']

    - name: Create timestamped backup directory
      file:
        path: "{{ backup_base_dir }}/backup-{{ backup_timestamp }}"
        state: directory
        mode: '0755'
        owner: root
        group: root
      tags: ['backup']

    - name: Create backup metadata file
      copy:
        content: |
          BACKUP METADATA
          ===============
          Backup Timestamp: {{ ansible_date_time.iso8601 }}
          Backup Server: {{ ansible_hostname }}
          Backup User: {{ ansible_user_id }}
          Files Backed Up:
          {% for file in files_to_backup %}
          - {{ file }}
          {% endfor %}
          Backup Retention: {{ backup_retention_days }} days
        dest: "{{ backup_base_dir }}/backup-{{ backup_timestamp }}/backup-metadata.txt"
        mode: '0644'
      tags: ['backup']

    - name: Create compressed backup archives for each directory
      archive:
        path: "{{ item }}"
        dest: "{{ backup_base_dir }}/backup-{{ backup_timestamp }}/{{ item | basename }}-{{ backup_timestamp }}.tar.gz"
        format: gz
      with_items: "{{ files_to_backup }}"
      tags: ['backup']

    - name: Set proper ownership and permissions for backup files
      file:
        path: "{{ backup_base_dir }}/backup-{{ backup_timestamp }}"
        owner: root
        group: root
        mode: '0755'
        recurse: yes
      tags: ['backup']

    - name: List created backup files
      find:
        paths: "{{ backup_base_dir }}/backup-{{ backup_timestamp }}"
        patterns: "*.tar.gz"
      register: backup_files
      tags: ['backup']

    - name: Display backup summary
      debug:
        msg:
          - "Backup completed successfully!"
          - "Backup Location: {{ backup_base_dir }}/backup-{{ backup_timestamp }}"
          - "Files Backed Up: {{ backup_files.files | length }}"
          - "Total Size: {{ (backup_files.files | map(attribute='size') | sum) | filesizeformat(True) }}"
      tags: ['backup']

    - name: Clean up old backups (older than retention period)
      shell: |
        find {{ backup_base_dir }} -type d -name "backup-*" -mtime +{{ backup_retention_days }} -exec rm -rf {} \; 2>/dev/null || true
      tags: ['cleanup']
      when: backup_retention_days > 0
```

**Playbook explanation:**
- **Variables**: Configurable backup paths, timestamps, and retention policies
- **Directory Setup**: Creates organized backup structure with timestamps
- **Metadata**: Records backup details for audit trails
- **Compression**: Creates compressed tar.gz archives for each directory
- **Permissions**: Sets proper ownership and security for backup files
- **Summary**: Provides detailed backup completion information
- **Cleanup**: Automatically removes old backups based on retention policy

**Save the file**: Press `Ctrl+O`, Enter, then `Ctrl+X`

![Backup Playbook Creation](./img/backup-playbook.png)

#### Step 8: Create Restore Playbook

**Objective**: Create a comprehensive restore playbook for recovering files from backup archives.

```bash
nano restore_files.yml
```

**Add the following playbook content:**
```yaml
- name: Restore files from backup archives
  hosts: backup_servers
  become: yes
  vars:
    backup_base_dir: "/backup"
    backup_timestamp: "{{ ansible_date_time.iso8601 | regex_replace('[:T]', '-') | regex_replace('\\..*', '') }}"
    restore_timestamp: "2024-01-01-12-00-00"  # Replace with actual backup timestamp

  tasks:
    - name: Check if backup exists
      stat:
        path: "{{ backup_base_dir }}/backup-{{ restore_timestamp }}"
      register: backup_check
      tags: ['verify']

    - name: Fail if backup doesn't exist
      fail:
        msg: "Backup directory {{ backup_base_dir }}/backup-{{ restore_timestamp }} not found!"
      when: not backup_check.stat.exists
      tags: ['verify']

    - name: List available backup files
      find:
        paths: "{{ backup_base_dir }}/backup-{{ restore_timestamp }}"
        patterns: "*.tar.gz"
      register: restore_files
      tags: ['verify']

    - name: Display restore options
      debug:
        msg: |
          Available files to restore:
          {% for file in restore_files.files %}
          - {{ file.path | basename }} ({{ (file.size / 1024 / 1024) | round(2) }} MB)
          {% endfor %}
      tags: ['verify']

    - name: Create restore confirmation file
      file:
        path: "{{ backup_base_dir }}/restore-confirmation.txt"
        state: touch
        mode: '0644'
      tags: ['restore']

    - name: Extract backup archives to restore location
      unarchive:
        src: "{{ item.path }}"
        dest: "/"
        remote_src: yes
        creates: "{{ item.path | dirname | basename | regex_replace('^(.*)-.*$', '\\1') }}/.ansible_restored"
      with_items: "{{ restore_files.files }}"
      tags: ['restore']

    - name: Verify restored files
      shell: |
        {% for file in restore_files.files %}
        {% set dirname = file.path | basename | regex_replace('^(.*)-.*\\.tar\\.gz$', '\\1') %}
        echo "=== Verifying {{ dirname }} ===" &&
        ls -la /{{ dirname }}/ | head -10 &&
        echo "Restore completed for {{ dirname }}"
        {% endfor %}
      register: restore_verification
      tags: ['verify']

    - name: Display restore summary
      debug:
        msg:
          - "Restore completed successfully!"
          - "Restored from: {{ backup_base_dir }}/backup-{{ restore_timestamp }}"
          - "Files Restored: {{ restore_files.files | length }}"
          - "Verification Details:"
          - "{{ restore_verification.stdout_lines | join('\n') }}"
      tags: ['restore']

    - name: Create restoration log
      copy:
        content: |
          RESTORE LOG
          ===========
          Restore Timestamp: {{ ansible_date_time.iso8601 }}
          Restored From: {{ restore_timestamp }}
          Files Restored: {{ restore_files.files | length }}
          Verification Status: Completed
        dest: "{{ backup_base_dir }}/restore-log-{{ ansible_date_time.iso8601 | regex_replace('[:T]', '-') | regex_replace('\\..*', '') }}.txt"
        mode: '0644'
      tags: ['restore']
```

**Playbook explanation:**
- **Backup Verification**: Checks if specified backup exists before attempting restore
- **File Listing**: Shows available files for selective restoration
- **Safe Restoration**: Uses `creates` parameter to avoid overwriting existing files
- **Verification**: Confirms successful restoration with file listings
- **Logging**: Creates detailed restoration logs for audit purposes

**Save the file**: Press `Ctrl+O`, Enter, then `Ctrl+X`

![Restore Playbook Creation](./img/restore-playbook.png)

---

### Phase 5: Execution and Testing

#### Step 9: Create Sample Files for Backup Testing

**Objective**: Create sample files to demonstrate the backup and restore process.

**SSH into the target server and create test files:**
```bash
# Create test directory structure
sudo mkdir -p /test-backup/{documents,configs,logs}

# Create sample files
sudo tee /test-backup/documents/important-doc.txt << 'EOF' > /dev/null
IMPORTANT DOCUMENT
==================
This is a critical file that needs to be backed up.
Created on: $(date)
Server: $(hostname)
EOF

sudo tee /test-backup/configs/app-config.conf << 'EOF' > /dev/null
# Application Configuration
database_host=localhost
port=5432
backup_enabled=true
EOF

sudo tee /test-backup/logs/application.log << 'EOF' > /dev/null
$(date): Application started
$(date): Processing data...
$(date): Backup operation completed
EOF

# Set proper permissions
sudo chmod 644 /test-backup/*/*
sudo chown root:root /test-backup/*/*
```

#### Step 10: Run the Backup Playbook

**Objective**: Execute the enhanced backup playbook to create compressed archives.

```bash
ansible-playbook -i inventory.ini backup_files.yml
```

**Command breakdown:**
- `-i inventory.ini`: Specify inventory file location
- `backup_files.yml`: Your comprehensive backup playbook

*Expected Output*:
```
PLAY [Comprehensive file backup with compression and metadata] ****************

TASK [Gathering Facts] ****************
ok: [target1]

TASK [Create backup base directory] ****************
changed: [target1]

TASK [Install required packages (tar, gzip)] ****************
ok: [target1]

TASK [Create timestamped backup directory] ****************
changed: [target1]

TASK [Create backup metadata file] ****************
changed: [target1]

TASK [Create compressed backup archives for each directory] ****************
changed: [target1] => (item=/etc)
changed: [target1] => (item=/home)
changed: [target1] => (item=/var/www)
changed: [target1] => (item=/var/log)

TASK [Set proper ownership and permissions for backup files] ****************
changed: [target1]

TASK [List created backup files] ****************
ok: [target1]

TASK [Display backup summary] ****************
ok: [target1]

PLAY RECAP ****************
target1: ok=9 changed=6 unreachable=0 failed=0
```

#### Step 11: Verify Backup Creation

**Objective**: Confirm that backup archives were created successfully.

**SSH into the target server and verify:**
```bash
# List backup directory
sudo ls -la /backup/

# Show backup contents
sudo ls -la /backup/backup-$(date +%Y-%m-%d-%H-%M-%S)/

# Check backup file sizes
sudo du -sh /backup/backup-$(date +%Y-%m-%d-%H-%M-%S)/*.tar.gz

# View backup metadata
sudo cat /backup/backup-$(date +%Y-%m-%d-%H-%M-%S)/backup-metadata.txt

# Test archive integrity
sudo tar -tzf /backup/backup-$(date +%Y-%m-%d-%H-%M-%S)/etc-$(date +%Y-%m-%d-%H-%M-%S).tar.gz | head -10
```

*Expected Output*:
```
/backup/ with timestamped backup directory
Compressed .tar.gz files for each backed up directory
Backup metadata showing timestamp, files, and retention policy
Archive contents listing when tested with tar -tzf
```

#### Step 12: Simulate File Loss and Test Restore

**Objective**: Demonstrate the restore process by simulating data loss and recovery.

**Simulate file loss:**
```bash
# Backup original files (for testing)
sudo cp -r /test-backup /test-backup-original

# Simulate data loss
sudo rm -rf /test-backup

# Verify files are gone
ls /test-backup
# Should show: "ls: cannot access '/test-backup': No such file or directory"
```

**Run the restore playbook:**
```bash
ansible-playbook -i inventory.ini restore_files.yml
```

**Verify file restoration:**
```bash
# Check if files were restored
ls -la /test-backup/

# Verify file contents
cat /test-backup/documents/important-doc.txt

# Compare with original
diff -r /test-backup /test-backup-original
```

*Expected Output*:
```
Restored directory structure and files
Original file contents intact
No differences between restored and original files
```

![Backup and Restore Verification](./img/backup-restore-verification.png)

---

## 🛠️ Troubleshooting Guide

### Common Issues and Solutions

| Problem | Symptoms | Solution |
|---------|----------|----------|
| **Permission Denied** | `Permission denied` errors during backup/restore | Verify sudo access, check SSH keys, ensure Ansible user has proper permissions |
| **Disk Space Full** | `No space left on device` during backup | Check available space: `df -h`, increase disk space, or adjust backup scope |
| **Backup Not Found** | `Backup directory not found` during restore | Verify backup timestamp, check backup directory exists, list available backups |
| **Archive Corruption** | `tar: Unexpected EOF` or extraction errors | Test archive integrity: `tar -tzf backup.tar.gz`, recreate if corrupted |
| **SSH Connection Issues** | `unreachable` in Ansible output | Verify SSH connectivity, check keys, ensure target server is accessible |
| **File Path Errors** | `No such file or directory` | Double-check file paths in playbooks, verify paths exist on target server |

### Debugging Commands

```bash
# Check available disk space
df -h

# List backup directories with timestamps
sudo ls -la /backup/ | grep backup-

# Check file permissions on target server
sudo ls -la /etc/passwd

# Test SSH connectivity
ansible -i inventory.ini backup_servers -m ping

# Check Ansible user permissions
ansible -i inventory.ini backup_servers -m command -a "whoami"

# Verify backup file integrity
sudo tar -tzf /backup/backup-*/etc-*.tar.gz | head -5

# Check system logs for errors
sudo tail -f /var/log/syslog | grep -i ansible
```

### Common Error Messages

**`FAILED! => {"changed": false, "msg": "No space left on device"}`**
- **Cause**: Insufficient disk space for backup archives
- **Solution**: Free up space, increase storage, or reduce backup scope

**`Backup directory ... not found`**
- **Cause**: Specified backup timestamp doesn't exist or wrong path
- **Solution**: List available backups, verify timestamp format

**`tar: Unexpected EOF in archive`**
- **Cause**: Archive file is corrupted or incomplete
- **Solution**: Recreate backup, check disk space during creation

---

## 📸 Evidence and Screenshots for Submission

### Required Screenshots

1. **Prerequisites Verification**
   - `evidence-01-prereq-verification.png` - OS, sudo, Ansible, and storage checks
   - `evidence-02-network-connectivity.png` - Network connectivity test

2. **SSH Configuration**
   - `evidence-03-ssh-keygen.png` - SSH key generation output
   - `evidence-04-ssh-copy-id.png` - Public key distribution
   - `evidence-05-ssh-connection.png` - Passwordless connection test

3. **Ansible Configuration**
   - `evidence-06-inventory-file.png` - Inventory file contents
   - `evidence-07-backup-playbook.png` - Enhanced backup playbook
   - `evidence-08-restore-playbook.png` - Restore playbook
   - `evidence-09-directory-structure.png` - Project directory structure

4. **Backup Operations**
   - `evidence-10-sample-files.png` - Test files created for backup
   - `evidence-11-backup-execution.png` - Backup playbook execution
   - `evidence-12-backup-directory.png` - Backup directory contents
   - `evidence-13-backup-metadata.png` - Backup metadata file contents
   - `evidence-14-backup-summary.png` - Backup completion summary

5. **Restore Operations**
   - `evidence-15-file-loss-simulation.png` - Simulated file deletion
   - `evidence-16-restore-execution.png` - Restore playbook execution
   - `evidence-17-restored-files.png` - Verification of restored files
   - `evidence-18-restore-verification.png` - File integrity verification

### Screenshot Naming Convention
All screenshots should be saved in the `img/` directory with descriptive names:
- `evidence-XX-description.png`
- Include terminal prompts and outputs
- Ensure text is readable and commands are visible
- Capture both successful and failed attempts (for troubleshooting evidence)

---

## 🎓 Key Concepts Learned

### Backup and Restore Fundamentals
- **Backup Strategy**: Regular, automated data protection
- **Compression**: Reducing storage requirements with tar.gz
- **Metadata**: Recording backup details for audit trails
- **Retention Policies**: Automatic cleanup of old backups
- **Verification**: Ensuring backup integrity and restore capability

### Ansible Advanced Features
- **Variables**: Dynamic configuration with `{{ }}` syntax
- **Loops**: Processing multiple items with `with_items`
- **Conditionals**: Smart decision making with `when` clauses
- **Error Handling**: Proper failure management and validation
- **File Operations**: Advanced file and archive management

### Data Protection Best Practices
- **3-2-1 Rule**: 3 copies, 2 media types, 1 offsite location
- **Automation**: Eliminates human error in backup processes
- **Monitoring**: Verification and alerting for backup success/failure
- **Security**: Proper permissions and access controls
- **Scalability**: Easy expansion to multiple servers

---

## 🔧 Advanced Configuration Options

### Remote Backup Storage
```yaml
- name: Backup to remote storage (NFS/SMB)
  hosts: backup_servers
  become: yes
  tasks:
    - name: Mount remote backup storage
      mount:
        path: /mnt/remote-backup
        src: "//backup-server/backups"
        fstype: cifs
        opts: "username=backupuser,password=backuppass"
        state: mounted

    - name: Copy backups to remote storage
      copy:
        src: "{{ backup_base_dir }}/"
        dest: "/mnt/remote-backup/{{ ansible_hostname }}/"
        remote_src: yes
```

### Database Backup Integration
```yaml
- name: Backup databases along with files
  hosts: backup_servers
  become: yes
  tasks:
    - name: Create database backup
      mysql_db:
        name: all
        state: dump
        target: "{{ backup_base_dir }}/database-backup.sql"

    - name: Compress database backup
      archive:
        path: "{{ backup_base_dir }}/database-backup.sql"
        dest: "{{ backup_base_dir }}/backup-{{ backup_timestamp }}/database-{{ backup_timestamp }}.sql.gz"
        format: gz
```

### Scheduled Backup with Cron
```yaml
- name: Schedule automated backups
  hosts: backup_servers
  become: yes
  tasks:
    - name: Create backup script
      copy:
        content: |
          #!/bin/bash
          ansible-playbook /path/to/backup_files.yml
        dest: /usr/local/bin/daily-backup.sh
        mode: '0755'

    - name: Schedule daily backup
      cron:
        name: "Daily Backup"
        minute: "0"
        hour: "2"
        job: "/usr/local/bin/daily-backup.sh"
```

---

## ✅ Project Checklist

- [ ] **Prerequisites verified** (OS, sudo, network, Ansible, storage)
- [ ] **SSH keys generated** and distributed to target servers
- [ ] **Inventory file created** with correct target server details
- [ ] **Enhanced backup playbook written** with compression and metadata
- [ ] **Restore playbook created** with verification and error handling
- [ ] **Sample files created** for testing backup and restore
- [ ] **Backup playbook executed** successfully
- [ ] **Backup archives verified** (compression, metadata, integrity)
- [ ] **Restore process tested** (simulation, execution, verification)
- [ ] **All screenshots captured** for evidence
- [ ] **Troubleshooting documented** (if applicable)

---

## 🚀 Next Steps

With backup and restore automation mastered, you can now:

1. **Database Backup Integration**: Add MySQL/PostgreSQL backup capabilities
2. **Remote Storage**: Configure backups to cloud storage or remote servers
3. **Incremental Backups**: Implement differential backup strategies
4. **Monitoring and Alerting**: Add email notifications for backup status
5. **Multi-Server Coordination**: Synchronize backups across server clusters
6. **Compliance and Audit**: Add detailed logging for regulatory requirements

---

## 🏆 Project Outcomes

By completing this project, you have:

✅ **Automated comprehensive backup** processes with compression and metadata
✅ **Implemented robust restore** procedures with verification and error handling
✅ **Created scalable solutions** for multi-server backup management
✅ **Applied data protection** best practices and retention policies
✅ **Verified automated processes** with comprehensive testing
✅ **Gained practical experience** with enterprise-grade backup automation
✅ **Documented the entire process** for submission and review

**Congratulations on mastering backup and restore automation with Ansible!** 🎉

This project demonstrates your ability to implement critical data protection strategies, making you ready for enterprise backup administration and disaster recovery scenarios.

For questions or issues, refer to the troubleshooting section or consult the official Ansible documentation.

---

## 📚 Additional Resources

- **Ansible Archive Module**: [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/archive_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/archive_module.html)
- **Ansible Unarchive Module**: [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/unarchive_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/unarchive_module.html)
- **Backup Best Practices**: [https://www.backblaze.com/blog/3-2-1-backup-strategy/](https://www.backblaze.com/blog/3-2-1-backup-strategy/)
- **Data Protection Guidelines**: [https://www.nist.gov/cyberframework/data-protection](https://www.nist.gov/cyberframework/data-protection)
- **Ansible Cron Module**: [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/cron_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/cron_module.html)
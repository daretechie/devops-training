Backup and Restore Files on a Linux Server using Ansible
Introduction
Data backup and restoration are essential practices for ensuring data safety and continuity in Linux server management. Ansible, an automation tool, simplifies these tasks by providing a scalable and repeatable solution. This project will guide you through creating Ansible playbooks to automate the backup and restore process for files on a Linux server.

Objectives
Understand the basics of Ansible and its role in automation.
Set up an Ansible environment for managing Linux servers.
Create a playbook to back up files to a remote or local directory.
Develop a playbook to restore files from a backup.
Test and verify the backup and restore processes.
Prerequisites
Linux Servers: At least one server to act as the target machine and an optional control machine for Ansible.
Ansible Installed: Ansible installed on the control machine. (Refer to the Ansible installation guide to install it if not already installed.)
SSH Access: SSH access between the control machine and target servers with public key authentication.
Tools: A text editor to create and edit Ansible playbooks.
Estimated Time
2-3 hours

Tasks Outline
Install and configure Ansible on the control machine.
Set up an inventory file for the target Linux server.
Create an Ansible playbook to back up files.
Create an Ansible playbook to restore files from a backup.
Test the backup and restore functionality.
Project Tasks
Task 1 - Install and Configure Ansible
Install Ansible on the control machine (Ubuntu example):


Copy
sudo apt update
sudo apt install ansible -y
Verify the installation:


Copy
ansible --version
Set up SSH key-based authentication between the control machine and target server:


Copy
ssh-keygen -t rsa
ssh-copy-id user@<target-server-ip>
Task 2 - Set Up the Ansible Inventory File
Create an inventory file to define the target server:


Copy
nano inventory.ini
Add the target server details:


Copy
[linux_servers]
target ansible_host=<target-server-ip> ansible_user=<user>
Task 3 - Create an Ansible Playbook to Back Up Files
Create a playbook file for backup:


Copy
nano backup.yml
Add the following playbook content:


Copy
- name: Backup files on the server
  hosts: linux_servers
  tasks:
    - name: Create backup directory
      file:
        path: /backup
        state: directory
        mode: '0755'

    - name: Copy files to backup directory
      copy:
        src: /path/to/files
        dest: /backup/
        remote_src: yes
Replace /path/to/files with the path of the files you want to back up.

Task 4 - Create an Ansible Playbook to Restore Files
Create a playbook file for restoration:


Copy
nano restore.yml
Add the following playbook content:


Copy
- name: Restore files from backup
  hosts: linux_servers
  tasks:
    - name: Copy files back to original location
      copy:
        src: /backup/
        dest: /path/to/files
        remote_src: yes
Replace /path/to/files with the original file location.

Task 5 - Test the Backup and Restore Functionality
Run the backup playbook:


Copy
ansible-playbook -i inventory.ini backup.yml
Verify the backup directory and files on the target server:


Copy
ls /backup
Run the restore playbook:


Copy
ansible-playbook -i inventory.ini restore.yml
Verify the restored files in the original location on the target server:


Copy
ls /path/to/files
Conclusion
This project introduced you to automating file backup and restoration on a Linux server using Ansible. You set up an Ansible environment, created playbooks for backup and restoration, and verified the process. With these skills, you can extend the playbooks to include more servers, schedule regular backups, or integrate advanced options like compression or encryption.


Previous step
Deploy and Configure Nginx Web Server using Ansible

Next step
Introduction to System Monitoring and Reliability
On this page:

Backup and Restore Files on a Linux Server using Ansible

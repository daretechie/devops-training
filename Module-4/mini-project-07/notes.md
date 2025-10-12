Automate User Creation on Linux Server using Ansible
Introduction
Managing user accounts is a common administrative task for Linux servers. Manually creating and managing user accounts can become tedious, especially on multiple servers. Ansible simplifies this process by automating user creation with playbooks. This project will guide you in creating an Ansible playbook to automate user creation on a Linux server.

Objectives
Understand the basics of Ansible and its automation capabilities.
Set up an Ansible environment to manage Linux servers.
Create an Ansible playbook to automate user creation.
Configure additional settings like home directory, groups, and SSH access.
Verify the user creation process and test access.
Prerequisites
Linux Servers: At least one Linux server to act as the target machine and an optional control machine for Ansible.
Ansible Installed: Ansible installed on the control machine. (Refer to the Ansible installation guide if you don't have Ansible already installed.)
SSH Access: SSH access between the control machine and target servers with public key authentication.
Tools: A text editor to create and edit Ansible playbooks.
Estimated Time: 1-2 hours.
Tasks Outline
Install and configure Ansible on the control machine.
Set up an inventory file for the target Linux server.
Create an Ansible playbook to automate user creation.
Configure additional user settings like groups and SSH access.
Verify user creation and test login.
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
Task 3 - Create an Ansible Playbook to Automate User Creation
Create a playbook file for user creation:


Copy
nano create_users.yml
Add the following playbook content:


Copy
- name: Automate user creation
  hosts: linux_servers
  become: yes
  tasks:
    - name: Create a new user
      user:
        name: "{"{ item.username "}}"
        state: present
        shell: /bin/bash
        create_home: yes
      with_items:
        - {" username: \"user1\" "}
        - {" username: \"user2\" "}
Task 4: Configure Additional User Settings
Update the playbook to include group and SSH key configuration:


Copy
- name: Automate user creation
  hosts: linux_servers
  become: yes
  tasks:
    - name: Create a new user with additional settings
      user:
        name: "{"{ item.username "}}"
        state: present
        shell: /bin/bash
        create_home: yes
        groups: "{"{ item.groups "}}"
      with_items:
        - {" username: \"user1\", groups: \"sudo\" "}
        - {" username: \"user2\", groups: \"docker\" "}

    - name: Add SSH key for the users
      authorized_key:
        user: "{"{ item.username "}}"
        state: present
        key: "{"{ lookup('file', item.ssh_key) "}}"
      with_items:
        - {" username: \"user1\", ssh_key: \"/path/to/user1.pub\" "}
        - {" username: \"user2\", ssh_key: \"/path/to/user2.pub\" "}
Replace /path/to/user1.pub and /path/to/user2.pub with the paths to the public SSH keys for each user.

Task 5 - Verify User Creation and Test Login
Run the playbook to create users:


Copy
ansible-playbook -i inventory.ini create_users.yml
Verify the users were created on the target server:


Copy
cat /etc/passwd
ls /home
Test SSH access for the newly created users:


Copy
ssh user1@<target-server-ip>
ssh user2@<target-server-ip>
Conclusion
In this project, you automated the creation of user accounts on a Linux server using Ansible. You learned how to write an Ansible playbook for user creation, configure additional settings like groups and SSH access, and verify the process. With these skills, you can manage user accounts efficiently across multiple servers and extend the playbook for advanced configurations like password policies and user deletion.


Previous step
Setting up Ansible on a Linux Server

Next step
Deploy and Configure Nginx Web Server using Ansible

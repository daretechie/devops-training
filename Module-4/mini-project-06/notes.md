Setting up Ansible on a Linux Server
Introduction
Ansible is a powerful automation tool that simplifies the management of IT infrastructure. Setting up Ansible on a Linux server is the first step toward leveraging its capabilities. This project will guide you through installing and configuring Ansible on a Linux server, allowing you to automate tasks and manage servers effectively.

Objectives
Understand what Ansible is and how it works.
Install and configure Ansible on a Linux control node.
Set up SSH key-based authentication for target nodes.
Create an Ansible inventory file.
Verify Ansible setup by running basic commands.
Prerequisites
Linux Machine: A Linux server or virtual machine to act as the control node.
Target Machine(s): At least one additional Linux server or virtual machine for Ansible to manage.
SSH Access: Access to target nodes with SSH.
Tools: Basic knowledge of the Linux command line and a text editor.
Estimated Time
1-2 hours

Tasks Outline
Install Ansible on the control node.
Configure SSH key-based authentication.
Create an inventory file for target machine(s).
Test Ansible connectivity to target machine(s).
Run a simple Ansible ad-hoc command.
Project Tasks
Task 1 - Install Ansible on the Control Node
Update the package repository


Copy
sudo apt update
Install Ansible:


Copy
sudo apt install ansible -y
Verify the installation:


Copy
ansible --version
The output should display the installed Ansible version like this

Task 2 - Configure SSH Key-Based Authentication
Generate an SSH key pair on the control node:


Copy
ssh-keygen -t rsa
Press Enter to accept the default path and passphrase.

Copy the public key to the target machine(s):


Copy
ssh-copy-id user@<target-server-ip>
Test SSH access without a password:


Copy
ssh user@<target-server-ip>
You have now successfully configured a passwordless SSH access.

Task 3 - Create an Inventory File
Create a directory for Ansible configuration:


Copy
mkdir ~/ansible
cd ~/ansible
Create an inventory file:


Copy
nano inventory.ini
Add target machine details to the inventory:


Copy
[linux_servers]
target1 ansible_host=<target1-ip> ansible_user=<user>
target2 ansible_host=<target2-ip> ansible_user=<user>
Save and close the file.

Task 4 - Test Ansible Connectivity
Test Ansible connectivity to the target machines:


Copy
ansible -i inventory.ini linux_servers -m ping
The output should show a pong response from each target machine.

Task 5 - Run a Simple Ansible Ad-Hoc Command
Run a command to check the uptime of target machines:


Copy
ansible -i inventory.ini linux_servers -m command -a "uptime"
Run a command to check disk usage:


Copy
ansible -i inventory.ini linux_servers -m shell -a "df -h"

Observe the outputs to confirm successful execution.

Conclusion
This project demonstrated how to set up Ansible on a Linux server and configure it to manage target machines. You installed Ansible, configured SSH access, created an inventory file, and verified connectivity using ad-hoc commands. With this foundation, you're now prepared to explore more advanced Ansible functionalities like writing playbooks and managing complex infrastructures.


Previous step
Ansible Beginners Tutorial

Next step
Automate User creation on Linux Server using Ansible
On this page:

Setting up Ansible on a Linux Server
1
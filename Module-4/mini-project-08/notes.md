Deploy and Configure Nginx Web Server using Ansible
Introduction
Nginx is a powerful and widely used web server known for its performance and flexibility. Deploying and configuring Nginx manually on multiple servers can be time-consuming, but with Ansible, this process becomes automated and efficient. This project will teach you how to use Ansible to deploy and configure an Nginx web server on a Linux machine.

Objectives
Understand how Ansible simplifies the deployment and configuration of applications.
Set up an Ansible environment for managing Linux servers.
Create and execute an Ansible playbook to install Nginx.
Configure a basic Nginx website using Ansible.
Verify the Nginx deployment.
Prerequisites
Linux Servers: At least one server to act as the target machine and an optional control machine for Ansible.
Ansible Installed: Ansible installed on the control machine. (Refer to the Ansible installation guide if needed.)
SSH Access: SSH access between the control machine and target servers with public key authentication.
Tools: A text editor to create and edit Ansible playbooks.
Estimated Time: 2-3 hours.
Tasks Outline
Install and configure Ansible on the control machine.
Set up an inventory file for the target Linux server.
Create an Ansible playbook to install Nginx.
Configure a custom Nginx website using Ansible.
Verify the Nginx deployment and access the website.
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
[web_servers]
target ansible_host=<target-server-ip> ansible_user=<user>
Task 3 - Create an Ansible Playbook to Install Nginx
Create a playbook file for installing Nginx:


Copy
nano install_nginx.yml
Add the following playbook content:


Copy
- name: Install Nginx on the server
  hosts: web_servers
  become: yes
  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: present
        update_cache: yes

    - name: Ensure Nginx is running
      service:
        name: nginx
        state: started
        enabled: yes
Save the file.

Task 4 - Configure a Custom Nginx Website Using Ansible
Create a playbook for Nginx website configuration:


Copy
nano configure_nginx.yml
Add the following playbook content:


Copy
- name: Configure Nginx website
  hosts: web_servers
  become: yes
  tasks:
    - name: Create website root directory
      file:
        path: /var/www/mywebsite
        state: directory
        mode: '0755'

    - name: Deploy HTML content
      copy:
        content: |
          <html>
          <head><title>Welcome to My Website</title></head>
          <body>
          <h1>Hello from Nginx!</h1>
          </body>
          </html>
        dest: /var/www/mywebsite/index.html

    - name: Configure Nginx server block
      copy:
        content: |
          server {"\n                 listen 80;\n                 server_name _;\n                 root /var/www/mywebsite;\n                 index index.html;\n                 location / {\n                     try_files $uri $uri/ =404;\n                 "}
          }
        dest: /etc/nginx/sites-available/mywebsite

    - name: Enable the Nginx server block
      file:
        src: /etc/nginx/sites-available/mywebsite
        dest: /etc/nginx/sites-enabled/mywebsite
        state: link

    - name: Remove default Nginx server block
      file:
        path: /etc/nginx/sites-enabled/default
        state: absent

    - name: Reload Nginx
      service:
        name: nginx
        state: reloaded
Task 5 - Verify the Nginx Deployment
Run the playbooks to install and configure Nginx:


Copy
ansible-playbook -i inventory.ini install_nginx.yml
ansible-playbook -i inventory.ini configure_nginx.yml
Verify Nginx is running on the target server:


Copy
curl http://<target-server-ip>
Open the target server's IP address in a web browser to access the custom website.

Conclusion
In this project, you used Ansible to automate the deployment and configuration of the Nginx web server on a Linux machine. You created reusable playbooks for installing Nginx and deploying a custom website. With these skills, you can manage multiple web servers efficiently, customize configurations further, and scale your deployment processes.


Previous step
Automate User creation on Linux Server using Ansible

Next step
Backup and Restore Files on a Linux Server using 
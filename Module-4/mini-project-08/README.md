# 🚀 Mini Project 8: Deploy and Configure Nginx Web Server using Ansible

## 🎯 Project Overview

**Nginx** is a high-performance, open-source web server renowned for its stability, rich feature set, and low resource consumption. This project demonstrates how to use **Ansible** to automate the deployment and configuration of Nginx web servers across multiple Linux systems, eliminating manual setup and ensuring consistency.

In this hands-on project, you'll learn to:
- Install and configure Ansible for web server management
- Create automated playbooks for Nginx deployment
- Configure custom websites with proper server blocks
- Manage Nginx services and verify deployments
- Understand web server automation best practices
- Scale web server deployments across multiple servers

This project builds on your Ansible foundation and demonstrates practical web server automation that can be extended for complex web application deployments.

![Nginx Ansible Automation Workflow](./img/nginx-ansible-automation.png)

---

## 📋 Prerequisites

### Technical Requirements
- **Control Node**: A Linux server or virtual machine (Ubuntu/Debian preferred)
- **Target Node(s)**: At least one Linux server/VM to deploy Nginx on
- **SSH Access**: Ability to connect to target nodes via SSH
- **User Privileges**: Sudo access on both control and target nodes
- **Network Connectivity**: Both nodes must be able to communicate
- **Ansible Installed**: Ansible installed on the control node

### Required Knowledge
- Basic Linux command line skills
- Understanding of SSH connections and web servers
- Text editor familiarity (nano, vim, etc.)
- Previous completion of Ansible setup projects (Mini Projects 6 & 7)

### Project Deliverables for Submission
1. **Screenshots** of each major step and command outputs
2. **Ansible playbook files** (inventory and deployment playbooks)
3. **Command outputs** showing successful Nginx installation and configuration
4. **Web server verification** evidence (curl output, browser access)
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

**Objective**: Organize your Ansible configuration files for the Nginx project.

```bash
mkdir ~/ansible-nginx-deployment
cd ~/ansible-nginx-deployment
```

**What this does:**
- Creates a dedicated directory for your Nginx deployment project
- Changes to that directory for easier file management

#### Step 6: Create Ansible Inventory File

**Objective**: Define which servers Ansible should manage for the web deployment.

```bash
nano inventory.ini
```

**Add the following content:**
```ini
[web_servers]
target1 ansible_host=TARGET_SERVER_IP ansible_user=YOUR_USERNAME

[webservers]
target1

[nginx_servers]
target1
```

**File explanation:**
- `[web_servers]`: Primary group for all web server targets
- `ansible_host`: IP address of the target server
- `ansible_user`: Username for SSH connections (should match your SSH user)
- Additional groups (`[webservers]`, `[nginx_servers]`) for organization and flexibility

**Save the file**: Press `Ctrl+O`, Enter, then `Ctrl+X`

![Inventory File Creation](./img/inventory-file.png)

---

### Phase 4: Nginx Deployment Playbook Creation

#### Step 7: Create Nginx Installation and Configuration Playbook

**Objective**: Create a comprehensive Ansible playbook to install and configure Nginx with a custom website.

```bash
nano deploy_nginx.yml
```

**Add the following playbook content:**
```yaml
- name: Deploy and configure Nginx web server
  hosts: web_servers
  become: yes
  tasks:
    - name: Update apt package cache
      apt:
        update_cache: yes
      tags: ['packages']

    - name: Install Nginx web server
      apt:
        name: nginx
        state: present
      tags: ['packages']

    - name: Ensure Nginx service is running and enabled
      service:
        name: nginx
        state: started
        enabled: yes
      tags: ['service']

    - name: Create website root directory
      file:
        path: /var/www/mywebsite
        state: directory
        mode: '0755'
        owner: www-data
        group: www-data
      tags: ['website']

    - name: Deploy custom HTML content
      copy:
        content: |
          <!DOCTYPE html>
          <html lang="en">
          <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>Welcome to My Ansible-Deployed Website</title>
              <style>
                  body {
                      font-family: Arial, sans-serif;
                      margin: 40px;
                      text-align: center;
                      background-color: #f0f0f0;
                  }
                  .container {
                      background-color: white;
                      padding: 40px;
                      border-radius: 10px;
                      box-shadow: 0 0 10px rgba(0,0,0,0.1);
                      max-width: 600px;
                      margin: 0 auto;
                  }
              </style>
          </head>
          <body>
              <div class="container">
                  <h1>🎉 Hello from Nginx!</h1>
                  <p>This website was automatically deployed using Ansible automation.</p>
                  <p><strong>Server IP:</strong> {{ ansible_default_ipv4.address }}</p>
                  <p><strong>Deployment Time:</strong> {{ ansible_date_time.iso8601 }}</p>
              </div>
          </body>
          </html>
        dest: /var/www/mywebsite/index.html
        mode: '0644'
      tags: ['website']

    - name: Create Nginx server block configuration
      copy:
        content: |
          server {
              listen 80;
              server_name _;
              root /var/www/mywebsite;
              index index.html;

              # Security headers
              add_header X-Frame-Options "SAMEORIGIN" always;
              add_header X-Content-Type-Options "nosniff" always;
              add_header X-XSS-Protection "1; mode=block" always;

              location / {
                  try_files $uri $uri/ =404;
              }

              # Health check endpoint
              location /health {
                  access_log off;
                  return 200 "healthy\n";
                  add_header Content-Type text/plain;
              }
          }
        dest: /etc/nginx/sites-available/mywebsite
        mode: '0644'
      tags: ['config']

    - name: Enable the Nginx server block
      file:
        src: /etc/nginx/sites-available/mywebsite
        dest: /etc/nginx/sites-enabled/mywebsite
        state: link
      tags: ['config']
      notify: reload nginx

    - name: Remove default Nginx server block
      file:
        path: /etc/nginx/sites-enabled/default
        state: absent
      tags: ['config']
      notify: reload nginx

    - name: Configure firewall to allow HTTP traffic
      ufw:
        rule: allow
        port: '80'
        proto: tcp
      tags: ['security']

  handlers:
    - name: reload nginx
      service:
        name: nginx
        state: reloaded
```

**Playbook explanation:**
- **Package Management**: Updates cache and installs Nginx
- **Service Management**: Ensures Nginx is running and enabled at boot
- **Website Deployment**: Creates directory structure and deploys custom HTML
- **Nginx Configuration**: Creates proper server block with security headers
- **Firewall Configuration**: Opens HTTP port for web access
- **Tags**: Allow selective execution of specific tasks
- **Handlers**: Automatically reload Nginx when configuration changes

**Save the file**: Press `Ctrl+O`, Enter, then `Ctrl+X`

![Playbook Creation](./img/playbook-creation.png)

---

### Phase 5: Execution and Testing

#### Step 8: Run the Nginx Deployment Playbook

**Objective**: Execute the playbook to install and configure Nginx with the custom website.

```bash
ansible-playbook -i inventory.ini deploy_nginx.yml
```

**Command breakdown:**
- `-i inventory.ini`: Specify inventory file location
- `deploy_nginx.yml`: Your comprehensive deployment playbook

*Expected Output*:
```
PLAY [Deploy and configure Nginx web server] ****************

TASK [Gathering Facts] ****************
ok: [target1]

TASK [Update apt package cache] ****************
changed: [target1]

TASK [Install Nginx web server] ****************
changed: [target1]

TASK [Ensure Nginx service is running and enabled] ****************
changed: [target1]

TASK [Create website root directory] ****************
changed: [target1]

TASK [Deploy custom HTML content] ****************
changed: [target1]

TASK [Create Nginx server block configuration] ****************
changed: [target1]

TASK [Enable the Nginx server block] ****************
changed: [target1]

TASK [Remove default Nginx server block] ****************
changed: [target1]

TASK [Configure firewall to allow HTTP traffic] ****************
changed: [target1]

PLAY RECAP ****************
target1: ok=10 changed=9 unreachable=0 failed=0
```

**What this means:**
- `ok=10`: All tasks completed successfully
- `changed=9`: Configuration changes were made
- `unreachable=0/failed=0`: No connection or execution failures

#### Step 9: Verify Nginx Installation

**Objective**: Confirm that Nginx is properly installed and running.

**SSH into the target server and verify:**
```bash
# Check Nginx service status
sudo systemctl status nginx

# Verify Nginx is listening on port 80
sudo netstat -tlnp | grep :80

# Check website files exist
ls -la /var/www/mywebsite/

# Verify Nginx configuration
sudo nginx -t

# Check firewall status
sudo ufw status
```

*Expected Output*:
```
● nginx.service - A high performance web server
   Loaded: loaded (/lib/systemd/system/nginx.service)
   Active: active (running) since ...
tcp  0  0 0.0.0.0:80  0.0.0.0:*  LISTEN  nginx
/var/www/mywebsite/ with index.html file
nginx: configuration file /etc/nginx/nginx.conf test is successful
ufw status showing port 80 allowed
```

#### Step 10: Test Website Accessibility

**Objective**: Verify that the deployed website is accessible via HTTP.

**Test website access:**
```bash
# Test from control node
curl http://target-server-ip

# Test health check endpoint
curl http://target-server-ip/health

# Open in web browser (if GUI available)
firefox http://target-server-ip
# OR
google-chrome http://target-server-ip
```

*Expected Output*:
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to My Ansible-Deployed Website</title>
    ...
</head>
<body>
    <div class="container">
        <h1>🎉 Hello from Nginx!</h1>
        <p>This website was automatically deployed using Ansible automation.</p>
        <p><strong>Server IP:</strong> [target-server-ip]</p>
        <p><strong>Deployment Time:</strong> [timestamp]</p>
    </div>
</body>
</html>
```

**Health check output:**
```
healthy
```

![Website Verification](./img/website-verification.png)

---

## 🛠️ Troubleshooting Guide

### Common Issues and Solutions

| Problem | Symptoms | Solution |
|---------|----------|----------|
| **Nginx Fails to Start** | `Job for nginx.service failed` | Check syntax: `sudo nginx -t`, verify ports not in use, check logs: `sudo tail -f /var/log/nginx/error.log` |
| **Permission Denied** | `Permission denied` errors | Verify sudo access, check file permissions, ensure proper SSH key authentication |
| **Connection Refused** | `Connection refused` on port 80 | Check firewall settings: `sudo ufw allow 80`, verify Nginx is running: `sudo systemctl status nginx` |
| **Website Not Accessible** | `curl` returns connection errors | Confirm target IP is correct, check network connectivity, verify firewall allows HTTP traffic |
| **Configuration Error** | `nginx: configuration file test failed` | Check server block syntax, verify file paths exist, test config: `sudo nginx -t` |
| **Service Not Enabled** | Nginx stops after reboot | Enable service: `sudo systemctl enable nginx`, check it's running: `sudo systemctl status nginx` |

### Debugging Commands

```bash
# Check Nginx service status with detailed info
sudo systemctl status nginx --no-pager -l

# View Nginx error logs
sudo tail -f /var/log/nginx/error.log

# Test Nginx configuration syntax
sudo nginx -t

# Check listening ports
sudo netstat -tlnp | grep nginx

# Test firewall configuration
sudo ufw status

# Check website file permissions
ls -la /var/www/mywebsite/

# Test connectivity from control node
curl -v http://target-server-ip

# Check Ansible connectivity
ansible -i inventory.ini web_servers -m ping
```

### Common Error Messages

**`nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)`**
- **Cause**: Another service is using port 80 (like Apache)
- **Solution**: Stop conflicting service: `sudo systemctl stop apache2`, or change Nginx port

**`nginx: [emerg] no such file or directory`**
- **Cause**: Website directory or files don't exist
- **Solution**: Verify paths in configuration, create missing directories

**`FAILED! => {"changed": false, "msg": "UFW is not available"}`**
- **Cause**: UFW firewall not installed
- **Solution**: Install UFW: `sudo apt install ufw`, or remove firewall tasks from playbook

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
   - `evidence-07-playbook-file.png` - Nginx deployment playbook
   - `evidence-08-directory-structure.png` - Project directory structure

4. **Deployment and Configuration**
   - `evidence-09-playbook-execution.png` - Ansible playbook execution output
   - `evidence-10-nginx-status.png` - Nginx service status verification
   - `evidence-11-website-files.png` - Website directory and file verification
   - `evidence-12-nginx-config.png` - Nginx configuration syntax check
   - `evidence-13-curl-test.png` - Website accessibility test with curl
   - `evidence-14-browser-access.png` - Website access via web browser
   - `evidence-15-health-check.png` - Health check endpoint verification

### Screenshot Naming Convention
All screenshots should be saved in the `img/` directory with descriptive names:
- `evidence-XX-description.png`
- Include terminal prompts and outputs
- Ensure text is readable and commands are visible
- Capture both successful and failed attempts (for troubleshooting evidence)

---

## 🎓 Key Concepts Learned

### Nginx Web Server Fundamentals
- **Web Server Role**: Serves HTTP/HTTPS content to clients
- **Server Blocks**: Virtual host configuration in Nginx
- **Static Content**: HTML, CSS, JavaScript file serving
- **Configuration Files**: `/etc/nginx/sites-available/` and `sites-enabled/`
- **Security Headers**: Protection against common web vulnerabilities

### Ansible Automation Concepts
- **Playbook Structure**: Organized automation workflows
- **Task Tags**: Selective execution of playbook sections
- **Handlers**: Event-driven task execution
- **File Management**: Creating, copying, and linking files
- **Service Management**: Starting, stopping, and reloading services

### Web Deployment Best Practices
- **Automation**: Consistent deployments across environments
- **Security**: Proper file permissions and firewall configuration
- **Monitoring**: Health check endpoints for load balancer integration
- **Scalability**: Foundation for multi-server deployments

---

## 🔧 Advanced Configuration Options

### Enhanced Nginx Configuration with SSL
```yaml
- name: Configure Nginx with SSL/TLS
  hosts: web_servers
  become: yes
  tasks:
    - name: Install Certbot for SSL certificates
      apt:
        name: certbot
        state: present

    - name: Obtain SSL certificate
      command: certbot --nginx -d your-domain.com
      args:
        creates: /etc/letsencrypt/live/your-domain.com/fullchain.pem
```

### Load Balancer Configuration
```yaml
- name: Configure Nginx as load balancer
  hosts: web_servers
  become: yes
  tasks:
    - name: Create load balancer configuration
      copy:
        content: |
          upstream backend {
              server web1.example.com;
              server web2.example.com;
          }
          server {
              listen 80;
              location / {
                  proxy_pass http://backend;
              }
          }
        dest: /etc/nginx/sites-available/load-balancer
```

### Website Template with Variables
```yaml
- name: Deploy website with dynamic content
  hosts: web_servers
  become: yes
  vars:
    company_name: "TechCorp"
    contact_email: "admin@techcorp.com"
  tasks:
    - name: Deploy dynamic HTML content
      template:
        src: ../templates/index.html.j2
        dest: /var/www/mywebsite/index.html
        mode: '0644'
```

---

## ✅ Project Checklist

- [ ] **Prerequisites verified** (OS, sudo, network, Ansible)
- [ ] **SSH keys generated** and distributed to target servers
- [ ] **Inventory file created** with correct target server details
- [ ] **Nginx deployment playbook written** with proper YAML syntax
- [ ] **Playbook executed** successfully (install + configure)
- [ ] **Nginx service verified** as running and enabled
- [ ] **Website accessibility tested** via curl and web browser
- [ ] **Nginx configuration validated** for syntax correctness
- [ ] **All screenshots captured** for evidence
- [ ] **Troubleshooting documented** (if applicable)

---

## 🚀 Next Steps

With Nginx web server automation mastered, you can now:

1. **SSL/TLS Configuration**: Add HTTPS support with Let's Encrypt certificates
2. **Load Balancing**: Configure Nginx as a reverse proxy and load balancer
3. **Multi-Server Deployment**: Deploy identical websites across multiple servers
4. **Content Management**: Automate content updates and deployments
5. **Monitoring Integration**: Add monitoring and alerting for web services
6. **Docker Integration**: Combine with Docker for containerized deployments

---

## 🏆 Project Outcomes

By completing this project, you have:

✅ **Automated Nginx deployment** across Linux servers using Ansible
✅ **Configured custom websites** with proper server blocks and security
✅ **Implemented firewall rules** for HTTP traffic
✅ **Created health check endpoints** for monitoring integration
✅ **Verified automated processes** with comprehensive testing
✅ **Gained practical experience** with web server automation
✅ **Documented the entire process** for submission and review

**Congratulations on mastering Nginx web server automation with Ansible!** 🎉

This project demonstrates your ability to automate web infrastructure deployment, making you ready for more complex web application automation scenarios.

For questions or issues, refer to the troubleshooting section or consult the official Ansible and Nginx documentation.

---

## 📚 Additional Resources

- **Ansible Nginx Documentation**: [https://docs.ansible.com/ansible/latest/collections/nginx/nginx_documentation.html](https://docs.ansible.com/ansible/latest/collections/nginx/nginx_documentation.html)
- **Nginx Official Documentation**: [https://nginx.org/en/docs/](https://nginx.org/en/docs/)
- **Ansible Service Module**: [https://docs.ansible.com/ansible/latest/collections/ansible/builtin/service_module.html](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/service_module.html)
- **Nginx Server Block Configuration**: [https://nginx.org/en/docs/http/server_names.html](https://nginx.org/en/docs/http/server_names.html)
- **Web Server Security Best Practices**: [https://owasp.org/www-project-top-ten/](https://owasp.org/www-project-top-ten/)
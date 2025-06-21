# 🚀 Cloud Server Setup with AWS EC2 (Ubuntu)

This guide walks you through creating a cloud-based Linux server (EC2 instance) on AWS and connecting to it securely via SSH from your local machine. Perfect for beginners learning cloud infrastructure, DevOps, or Linux administration.

---

## 📦 Step 1: AWS EC2 Server Provisioning

### ✅ Prerequisites

- A valid **AWS account** ([Create one here](https://aws.amazon.com/free))
- A local computer (Windows/macOS/Linux)
- Internet access

### 🔧 EC2 Instance Setup

1. **Sign in to AWS Console**
2. Navigate to: `Services` → **EC2**
3. On the left sidebar, click **Instances**
4. Click **Launch instance**
5. Choose an **Ubuntu Server (Free tier eligible)**
6. Follow default configuration, name your instance, and download your `.pem` key file securely
7. Launch the instance

📷 _Refer to screenshot:_
![AWS EC2 Launch](/Module-1/mini-project-5/img/ec2.png)

---

## 🔑 Step 2: Connecting to the Server (SSH)

### 🧰 Required SSH Clients

**Windows:**

- [MobaXterm](https://mobaxterm.mobatek.net/download.html) ✅ recommended
- Git Bash
- PuTTY
- PowerShell

**macOS/Linux:**

- Use built-in **Terminal**

📷 _Sample Terminal Screenshot:_
![Mac Terminal](/Module-1/mini-project-5/img/terminal.png)

---

### 🛡️ Secure Connection Using SSH

1. Move your downloaded `.pem` file to a safe location (e.g. `Downloads` folder)
2. Open Terminal (or MobaXterm)
3. Navigate to the `.pem` file:

```bash
cd ~/Downloads
```

4. Make your `.pem` file readable only by you (Linux/macOS only):

```bash
chmod 400 ubuntu.pem
```

5. Connect to your EC2 instance using:

```bash
ssh -i "ubuntu.pem" ubuntu@<PUBLIC_IP_ADDRESS>
```

📝 _Replace `<PUBLIC_IP_ADDRESS>` with the actual IP shown in your EC2 dashboard._

📷 _Expected Output on Successful Connection:_
![SSH Login Success](/Module-1/mini-project-5/img/terminal.png)

---

## 📦 Step 3: Linux Package Manager (APT/YUM)

### 🔄 Update Package Index

**Ubuntu/Debian:**

```bash
sudo apt update
```

**Red Hat/Fedora (optional):**

```bash
sudo yum update
```

---

### 📥 Install Sample Tool: `tree`

**Ubuntu/Debian:**

```bash
sudo apt install tree
```

**Red Hat/Fedora:**

```bash
sudo yum install tree
```

✅ To verify:

```bash
tree ~/Downloads
```

---

### 🆙 Upgrade Installed Packages

```bash
sudo apt upgrade
```

---

### ❌ Remove Installed Tool

```bash
sudo apt remove tree
```

---

## 🧪 Practice Challenge

Install **nginx** on your Ubuntu server:

```bash
sudo apt install nginx
```

Then verify by checking the Nginx service:

```bash
systemctl status nginx
```

---

## ✅ Summary

You now know how to:

- Launch and configure a Linux server on AWS
- Securely connect using SSH
- Use Linux package managers (apt/yum)
- Install, verify, and remove packages

---

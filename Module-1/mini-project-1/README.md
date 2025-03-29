# DevOps Environment Setup Guide

This guide provides step-by-step instructions to set up a DevOps environment with essential tools such as Git, Visual Studio Code, VirtualBox, Ubuntu, and GitHub.

## **Prerequisites**
- **Internet Connection** – Required for downloading tools and accessing online resources.
- **Computer Requirements** – Minimum **8GB RAM** (64-bit recommended) for running virtual machines.

## **Required Installations**

## **1. Install Visual Studio Code**

VS Code is a lightweight but powerful code editor.

### **Installation Steps:**

- Download from [VS Code Official Site](https://code.visualstudio.com/).
- Install using the setup wizard.
- Open VS Code and check installation.

![Visual Studio Code Welcome Screen](img/vscode.png)

## **2. Git**
Git is a version control system for tracking changes in code.

- **Download**: [Git for Windows](https://git-scm.com/download/win)
- **Installation Steps**:
  1. Download and run the `.exe` installer.
  2. Select default options for **command-line integration** and **OpenSSL** security.
  3. Click "Finish" to complete the installation.

## **2.1. Install Git**

### **Installation Commands:**

```sh
sudo apt update
sudo apt install git -y
```

### **Verify Installation:**

```sh
git --version
```

### **Basic Git Setup:**

```sh
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"
git init
git add .
git commit -m "Initial commit"
```

![Git Installation Confirmation](img/git.png)

### **3. VirtualBox (For Running Ubuntu)**
VirtualBox allows you to run virtual machines like Ubuntu.

- **Download**: [Oracle VirtualBox](https://www.virtualbox.org/)
- **Installation Steps**:
  1. Download the Windows **host** version.
  2. Run the `.exe` installer and follow the wizard.
  3. Click "Finish" after installation.

### **Installation Commands:**

```sh
sudo apt update
sudo apt install virtualbox -y
```
![Oracle VirtualBox Manager Welcome Screen](img/vm.png)


### **4. Ubuntu on VirtualBox (Linux Environment Setup)**
- **Download Ubuntu ISO**: [Ubuntu Official Site](https://ubuntu.com/download/desktop)
- **Steps to Install Ubuntu on VirtualBox**:
  1. Open VirtualBox and create a new virtual machine (**Linux → Ubuntu**).
  2. Allocate at least **2GB RAM** and create a **Virtual Hard Disk**.
  3. Select the downloaded Ubuntu `.iso` file.
  4. Start the Virtual Machine and follow the Ubuntu installation process.
  ### **Create and Run Ubuntu VM:**

```sh
vagrant init ubuntu/bionic64
vagrant up
```
  ![Ubuntu Login Prompt in VirtualBox](img/ubuntu.jpg)
  
  
## **Required Account Setups**
- **GitHub Account**: [Sign Up on GitHub](https://github.com/)
Create a repository and push a sample project.
![GitHub User Account Setup](img/github-account.png)

- **AWS Account**: [AWS Free Tier](https://aws.amazon.com/free/) (Requires a credit card with at least $1 balance). Set up an EC2 instance for cloud deployment.
![AWS User Account Setup](img/aws-account.png)


## **Conclusion**

This guide provides essential DevOps setup instructions with proper commands and screenshots.

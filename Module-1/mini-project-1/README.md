# **Tech Environment Setup (Windows)**

## **Introduction**

This guide provides step-by-step instructions for setting up a tech environment on Windows for the DevOps program. It covers essential software installations, account setups, and troubleshooting tips.

## **Prerequisites**

- **Internet Connection** – Required for downloading tools and accessing online resources.
- **Computer Requirements** – Minimum **8GB RAM** (64-bit recommended) for running virtual machines.

## **Required Installations**

### **1. Visual Studio Code (VS Code)**

- **Download**: [VS Code Official Website](https://code.visualstudio.com/)
- **Installation Steps**:
  - Download the Windows installer.
  - Run the installer (`.exe` file).
  - Click "Next" through the installation wizard.
  - Click "Finish" to complete the installation.
- **Launch**: Open from the Start Menu or search for **VS Code** in Windows search.

### **2. Git**

- **Download**: [Git for Windows](https://git-scm.com/download/win)
- **Installation Steps**:
  - Download and run the `.exe` installer.
  - Select default options for **command-line integration** and **OpenSSL** security.
  - Click "Finish" to complete the installation.
- **Verify Installation**: Open **Git Bash** and run:
  ```sh
  git --version
  ```

### **3. VirtualBox (For Running Ubuntu)**

- **Download**: [Oracle VirtualBox](https://www.virtualbox.org/)
- **Installation Steps**:
  - Download the Windows **host** version.
  - Run the `.exe` installer and follow the wizard.
  - Click "Finish" after installation.
- **Launch**: Open from the Start Menu or search **VirtualBox** in Windows search.

### **4. Ubuntu on VirtualBox (Linux Environment Setup)**

- **Download Ubuntu ISO**: [Ubuntu Official Site](https://ubuntu.com/download/desktop)
- **Steps to Install Ubuntu on VirtualBox**:
  - Open VirtualBox and create a new virtual machine (**Linux → Ubuntu**).
  - Allocate at least **2GB RAM** and create a **Virtual Hard Disk**.
  - Select the downloaded Ubuntu `.iso` file.
  - Start the Virtual Machine and install Ubuntu.

## **Required Account Setups**

- **GitHub Account**: [Sign Up on GitHub](https://github.com/)
- **AWS Account**: [AWS Free Tier](https://aws.amazon.com/free/) (Requires a credit card with at least $1 balance).

## **Troubleshooting & Common Errors**

- **Virtualization Not Enabled**: [Enable Virtualization](https://www.youtube.com/watch?v=MOuTxfzCvMY)
- **C++ Redistributable Error**: [Fix C++ Error](https://www.youtube.com/watch?v=xKTKgjUHu48)

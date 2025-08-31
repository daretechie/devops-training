# Jenkins Freestyle Project Implementation Guide

## Project Overview

This guide demonstrates creating a Jenkins Freestyle project with GitHub integration and automated webhook triggers. All steps include verification checkpoints and expected outcomes.

## Prerequisites

- **Jenkins Server**: Running on `http://your-server-ip:8080`
- **GitHub Account**: With repository creation permissions
- **Network Access**: Jenkins server accessible from GitHub webhooks

## Implementation Steps

### 1. Creating Jenkins Freestyle Job

#### **Step 1.1: Access Jenkins Dashboard**

1. Navigate to Jenkins URL: `http://your-server-ip:8080`
2. Login with admin credentials
3. Verify dashboard displays successfully

![Jenkins Dashboard](screenshots/jenkins-dashboard.png)
_Expected: Main dashboard with "New Item" visible in left menu_

#### **Step 1.2: Create New Freestyle Project**

1. Click **"New Item"** from left navigation menu
2. Enter job name: `my-first-job`
3. Select **"Freestyle project"** radio button
4. Click **"OK"** button

![Creating Freestyle Project](screenshots/create-freestyle-job.png)
_Expected: Job creation form with name field and project type selection_

#### **Step 1.3: Initial Job Configuration**

1. Configuration page opens automatically
2. Add description: "First Jenkins freestyle project for CI/CD automation"
3. Leave default settings unchanged
4. Click **"Save"** at bottom

![Job Configuration Page](screenshots/job-config-initial.png)
_Expected: Configuration page with multiple sections (General, Source Code Management, Build Triggers, etc.)_

#### **Step 1.4: Verify Job Creation**

- Return to dashboard
- Confirm `my-first-job` appears in project list
- Status shows "Never built" initially

![Job Created Successfully](screenshots/job-created-verification.png)
_Expected: Dashboard showing newly created job in project list_

### 2. GitHub Repository Setup

#### **Step 2.1: Create GitHub Repository**

1. Login to GitHub account
2. Click **"New repository"** button
3. Repository name: `jenkins-scm`
4. Check **"Add a README file"**
5. Click **"Create repository"**

![GitHub Repository Creation](screenshots/github-repo-creation.png)
_Expected: New repository with README.md file visible_

#### **Step 2.2: Copy Repository URL**

1. Click green **"Code"** button
2. Copy HTTPS URL: `https://github.com/username/jenkins-scm.git`
3. Keep this URL for Jenkins configuration

![Repository URL](screenshots/github-repo-url.png)
_Expected: Repository page with clone URL visible_

### 3. Connecting Jenkins to GitHub

#### **Step 3.1: Configure Source Code Management**

1. Go to `my-first-job` configuration
2. Navigate to **"Source Code Management"** section
3. Select **"Git"** radio button
4. Paste repository URL in **"Repository URL"** field
5. Verify **"Branch Specifier"** shows `*/main`

![SCM Configuration](screenshots/jenkins-scm-config.png)
_Expected: Git configuration section with repository URL filled_

#### **Step 3.2: Test Repository Connection**

1. Click **"Save"** to apply configuration
2. Click **"Build Now"** from job page
3. Monitor build progress in **"Build History"**

![Manual Build Execution](screenshots/manual-build-execution.png)
_Expected: Build #1 appears in build history_

#### **Step 3.3: Verify Build Success**

1. Click on build number (e.g., #1)
2. Check **"Console Output"**
3. Confirm successful repository checkout

![Build Console Output](screenshots/build-console-output.png)
_Expected: Console showing successful Git clone and checkout completion_

## Sample Console Output:

```
Started by user admin
Running as SYSTEM
Building in workspace /var/jenkins_home/workspace/my-first-job
The recommended git tool is: NONE
using credential
 > git rev-parse --resolve-git-dir /var/jenkins_home/workspace/my-first-job/.git
Fetching changes from the remote Git repository
 > git config remote.origin.url https://github.com/username/jenkins-scm.git
Fetching upstream changes from https://github.com/username/jenkins-scm.git
 > git --version
 > git --version
 > git fetch --tags --force --progress -- https://github.com/username/jenkins-scm.git +refs/heads/*:refs/remotes/origin/*
 > git rev-parse refs/remotes/origin/main^{commit}
Checking out Revision abc123def456 (refs/remotes/origin/main)
 > git config core.sparsecheckout
 > git checkout -f abc123def456
Commit message: "Initial commit"
First time build. Skipping changelog.
Finished: SUCCESS
```

### 4. Configuring Automated Build Triggers

#### **Step 4.1: Enable GitHub Webhook Trigger**

1. Open `my-first-job` configuration
2. Navigate to **"Build Triggers"** section
3. Check **"GitHub hook trigger for GITScm polling"**
4. Click **"Save"**

![Build Triggers Setup](screenshots/build-triggers-webhook.png)
_Expected: Build Triggers section with GitHub webhook option enabled_

#### **Step 4.2: Configure GitHub Webhook**

1. Go to GitHub repository **Settings**
2. Click **"Webhooks"** in left menu
3. Click **"Add webhook"** button
4. Configure webhook:
   - **Payload URL**: `http://jenkins-ip:8080/github-webhook/`
   - **Content type**: `application/json`
   - **Events**: Select "Just the push event"
   - **Active**: Checked

![GitHub Webhook Configuration](screenshots/github-webhook-config.png)
_Expected: Webhook configuration form with Jenkins payload URL_

#### **Step 4.3: Test Automated Trigger**

1. Edit README.md file in GitHub repository
2. Add content: "Testing Jenkins webhook automation"
3. Commit changes with message: "Test webhook trigger"
4. Push to main branch

![GitHub File Edit](screenshots/github-file-edit.png)
_Expected: GitHub file editor with changes ready to commit_

#### **Step 4.4: Verify Automatic Build**

1. Return to Jenkins dashboard
2. Check `my-first-job` for new build
3. Verify build triggered automatically without manual intervention

![Automatic Build Triggered](screenshots/automatic-build-verification.png)
_Expected: New build (#2) appears automatically in build history_

## Troubleshooting Guide

### **Issue**: Job Creation Fails

**Symptoms**: Error message when clicking "OK"
**Solutions**:

- Verify Jenkins has sufficient disk space
- Check job name contains only valid characters (letters, numbers, hyphens)
- Restart Jenkins service if persistent issues occur

### **Issue**: GitHub Repository Not Accessible

**Symptoms**: "Failed to connect to repository" error
**Solutions**:

- Verify repository URL syntax: `https://github.com/username/repo.git`
- Check repository visibility (public vs private)
- Configure GitHub credentials in Jenkins if repository is private
- Test network connectivity: `curl -I https://github.com`

### **Issue**: Build Fails with Git Errors

**Symptoms**: Console shows Git command failures
**Solutions**:

- Verify Git is installed on Jenkins server
- Check branch name matches repository default branch
- Ensure Jenkins user has Git access permissions
- Clear workspace and retry build

### **Issue**: Webhook Not Triggering Builds

**Symptoms**: Manual builds work, but GitHub pushes don't trigger builds
**Solutions**:

- Verify webhook URL format: `http://jenkins-ip:8080/github-webhook/`
- Check Jenkins server accessibility from internet
- Confirm webhook shows green checkmark in GitHub
- Review webhook delivery logs in GitHub settings
- Ensure firewall allows inbound traffic on port 8080

### **Issue**: Webhook SSL/TLS Errors

**Symptoms**: GitHub webhook delivery fails with SSL errors
**Solutions**:

- Use HTTP instead of HTTPS for initial testing
- Configure proper SSL certificates on Jenkins
- Add GitHub IPs to firewall whitelist
- Test webhook delivery manually from GitHub interface

### **Issue**: Build Queue Stuck

**Symptoms**: Builds remain in queue without executing
**Solutions**:

- Check Jenkins executors availability
- Verify no jobs blocking the queue
- Restart Jenkins service if needed
- Monitor system resources (CPU, memory, disk)

## Verification Checklist

Before proceeding, ensure each item is completed:

- [ ] Jenkins dashboard accessible and functional
- [ ] `my-first-job` created and visible in project list
- [ ] GitHub repository `jenkins-scm` created with README.md
- [ ] SCM configuration shows correct repository URL
- [ ] Manual build executes successfully
- [ ] Console output shows successful Git checkout
- [ ] GitHub webhook configured with correct payload URL
- [ ] Webhook delivery shows successful ping
- [ ] File modification triggers automatic build
- [ ] Build history shows both manual and automatic builds

## Expected Results Summary

**Manual Build Success Indicators**:

- Build status: SUCCESS (blue ball icon)
- Console output: "Finished: SUCCESS"
- Workspace contains repository files

**Webhook Automation Success Indicators**:

- GitHub webhook shows green checkmark
- File changes trigger immediate builds
- Build history shows sequential build numbers
- No manual intervention required for new builds

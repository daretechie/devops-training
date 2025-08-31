# Jenkins Freestyle Project Setup Guide

## Overview

A Jenkins job is a unit of work that automates build and deployment processes. This guide covers creating freestyle projects, connecting to source code management, and configuring automated triggers.

## What is a Jenkins Job?

A Jenkins job represents specific tasks that need automation, including:

- Code compilation
- Test execution
- Application packaging
- Server deployment

Each job contains build steps, post-build actions, and configuration settings that define execution parameters.

## Creating a Freestyle Project

### Step 1: Access Jenkins Dashboard

1. Open web browser and navigate to Jenkins URL (typically `http://server-ip:8080`)
2. Log in with admin credentials
3. Verify dashboard loads successfully

### Step 2: Create New Job

1. From Jenkins dashboard, click **"New Item"** in left menu

![Jenkins Dashboard - New Item](placeholder-new-item.png)

2. Enter job name: `my-first-job`
3. Select **"Freestyle project"** from available options
4. Click **OK** to proceed

![Freestyle Project Creation](placeholder-freestyle-creation.png)

### Step 3: Initial Configuration

1. Job configuration page opens automatically
2. Add job description (optional): "My first Jenkins freestyle project"
3. Leave other default settings unchanged for now
4. Click **"Save"** at bottom of page

![Initial Job Configuration](placeholder-initial-config.png)

### Step 4: Verify Job Creation

1. Return to Jenkins dashboard
2. Confirm `my-first-job` appears in project list
3. Job status should show as "Never built"

![Job Verification](placeholder-job-verification.png)

## Connecting to Source Code Management

### Prerequisites

- GitHub repository access
- Jenkins with internet connectivity

### Step 1: Create GitHub Repository

1. Create new repository named `jenkins-scm`
2. Initialize with README.md file
3. Ensure default branch is `main`

### Step 2: Configure Jenkins SCM

1. In job configuration, locate **"Source Code Management"** section
2. Select **Git**
3. Enter repository URL: `https://github.com/username/jenkins-scm.git`
4. Verify branch specifier shows `*/main`

![SCM Configuration](placeholder-scm-config.png)

### Step 3: Test Connection

1. Click **"Save"**
2. Click **"Build Now"**
3. Verify successful connection in build history

![Build Success](placeholder-build-success.png)

## Configuring Build Triggers

### Webhook Automation Setup

Manual builds are inefficient. Configure webhooks for automatic triggering when code changes.

### Step 1: Enable GitHub Webhook Trigger

1. Click **"Configure"** on your job
2. Navigate to **"Build Triggers"** section
3. Check **"GitHub hook trigger for GITScm polling"**

![Build Triggers Configuration](placeholder-build-triggers.png)

### Step 2: Create GitHub Webhook

1. Go to GitHub repository settings
2. Click **"Webhooks"** → **"Add webhook"**
3. Enter payload URL:
   - **For localhost**: `http://localhost:8080/github-webhook/`
   - **For public IP**: `http://your-public-ip:8080/github-webhook/`
4. Content type: `application/json`
5. Select **"Just the push event"**
6. Ensure webhook is active

![GitHub Webhook Setup](placeholder-github-webhook.png)

### Step 3: Test Automation

1. Edit README.md in repository
2. Commit and push changes
3. Verify automatic build triggers in Jenkins

![Automatic Build Trigger](placeholder-auto-build.png)

## Troubleshooting

### Common Issues and Solutions

#### Connection Problems

**Issue**: Repository URL not accessible

- **Solution**: Verify URL syntax and repository permissions
- **Check**: Network connectivity between Jenkins and GitHub

**Issue**: Authentication failures

- **Solution**: Configure GitHub credentials in Jenkins
- **Path**: Manage Jenkins → Manage Credentials → Add GitHub token

#### Webhook Issues

**Issue**: Webhook not triggering builds

- **Solution**:
  - **Localhost users**: GitHub cannot reach localhost URLs. Use ngrok or similar tunneling service:
    ```bash
    ngrok http 8080
    ```
    Then use the ngrok URL: `https://your-ngrok-url.ngrok.io/github-webhook/`
  - **Public server**: Verify webhook URL format: `http://your-public-ip:8080/github-webhook/`
- **Check**: Jenkins IP accessibility from GitHub servers
- **Verify**: Firewall rules allow port 8080 traffic

**Issue**: SSL certificate errors

- **Solution**: Use HTTP instead of HTTPS for initial setup
- **Alternative**: Configure proper SSL certificates

#### Build Failures

**Issue**: Build fails immediately

- **Solution**: Check Jenkins console output for specific errors
- **Verify**: Repository branch exists and is accessible
- **Check**: Build environment has required tools

#### Network Configuration

**Issue**: GitHub cannot reach Jenkins webhook (localhost setup)

- **Solution**: Use tunneling service like ngrok to expose localhost:
  ```bash
  ngrok http 8080
  ```
  Use the generated URL: `https://abc123.ngrok.io/github-webhook/`
- **Alternative**: Deploy Jenkins on cloud instance with public IP

**Issue**: GitHub cannot reach Jenkins webhook (public server)

- **Solution**: Ensure Jenkins server has public IP or use ngrok for testing
- **Alternative**: Configure reverse proxy with proper SSL

## Best Practices

### Security Considerations

- Use personal access tokens instead of passwords
- Limit webhook payload to push events only
- Regularly rotate authentication credentials

### Performance Optimization

- Configure polling intervals appropriately
- Use lightweight build steps for testing
- Monitor build queue for bottlenecks

### Monitoring and Maintenance

- Review build logs regularly
- Set up email notifications for failed builds
- Document job configurations for team reference

## Key Concepts

**Freestyle Project**: Basic Jenkins job type offering maximum flexibility for custom build processes.

**Source Code Management (SCM)**: Integration layer connecting Jenkins to version control systems like Git.

**Build Trigger**: Mechanism that initiates job execution based on specific events or schedules.

**Webhook**: HTTP callback that automatically notifies Jenkins of repository changes.

**Build Step**: Individual action performed during job execution (compile, test, deploy).

## Next Steps

After successful setup:

1. Add build steps for your specific project needs
2. Configure post-build actions (notifications, artifacts)
3. Explore pipeline-as-code with Jenkinsfiles
4. Set up multi-branch pipelines for complex workflows

This foundation enables automated CI/CD workflows that respond to code changes automatically, eliminating manual intervention and reducing deployment errors.

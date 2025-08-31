# Jenkins Pipeline Job

## Overview

A Jenkins pipeline job defines and automates a series of steps in the software delivery process. It enables scripting and organizing entire build, test, and deployment workflows. Jenkins pipelines facilitate seamless integration of continuous integration and continuous delivery (CI/CD) practices into software development by allowing teams to define, visualize, and execute complex processes as code.

## Prerequisites

- Jenkins server running and accessible
- GitHub repository with source code
- Basic understanding of Docker concepts
- Administrative access to Jenkins instance

## Creating a Pipeline Job

### Step 1: Create New Pipeline Job

1. Navigate to Jenkins dashboard
2. Click **"New Item"** from the left sidebar

![Creating new Jenkins item](images/new-item-dashboard.png)

3. Enter job name: "My pipeline job"
4. Select **"Pipeline"** as job type
5. Click **"OK"**

![Pipeline job creation](images/create-pipeline-job.png)

### Step 2: Configure Build Triggers

Set up automatic triggering when code changes occur:

1. In job configuration, scroll to **"Build Triggers"** section
2. Select **"GitHub hook trigger for GITScm polling"**
3. Save configuration

![Build trigger configuration](images/build-trigger-config.png)

**Note:** Ensure GitHub webhook is already configured to point to Jenkins server endpoint.

## Writing Pipeline Scripts

Jenkins supports two pipeline syntax types:

- **Declarative Syntax:** Structured, domain-specific language (recommended for beginners)
- **Scripted Syntax:** More flexible, suitable for complex requirements

### Basic Pipeline Structure

```groovy
pipeline {
    agent any

    stages {
        stage('Connect To Github') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/username/repository.git']])
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t dockerfile .'
                }
            }
        }
        stage('Run Docker Container') {
            steps {
                script {
                    sh 'docker run -itd -p 8081:80 dockerfile'
                }
            }
        }
    }
}
```

### Pipeline Components Explanation

#### Agent Configuration

```groovy
agent any
```

Specifies pipeline can run on any available Jenkins agent (master or node).

#### Stages Block

Contains sequential stages representing different phases of the delivery process.

#### Stage 1: GitHub Connection

```groovy
stage('Connect To Github') {
    steps {
        checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'repository-url']])
    }
}
```

- Checks out source code from specified GitHub repository
- Uses main branch by default
- Downloads repository contents to Jenkins workspace

#### Stage 2: Docker Image Build

```groovy
stage('Build Docker Image') {
    steps {
        script {
            sh 'docker build -t dockerfile .'
        }
    }
}
```

- Creates Docker image using Dockerfile in repository root
- Tags image as 'dockerfile'
- Executes shell command within Jenkins environment

#### Stage 3: Container Deployment

```groovy
stage('Run Docker Container') {
    steps {
        script {
            sh 'docker run -itd -p 8081:80 dockerfile'
        }
    }
}
```

- Runs container in detached mode (-d flag)
- Maps host port 8081 to container port 80
- Uses previously built Docker image

## Generating Pipeline Syntax

### Using Pipeline Syntax Generator

1. In pipeline job configuration, click **"Pipeline Syntax"**

![Pipeline syntax generator](images/pipeline-syntax-button.png)

2. Select **"checkout: Check out from version control"** from dropdown

![Checkout option selection](images/checkout-selection.png)

3. Enter repository URL and branch information
4. Click **"Generate Pipeline Script"**

![Syntax generation](images/generate-syntax.png)

5. Copy generated script and replace in pipeline configuration

## Docker Installation

Before running Docker commands in Jenkins pipeline, install Docker on the Jenkins server instance.

### Installation Steps

1. Create installation script file:

```bash
nano docker-install.sh
```

2. Add Docker installation commands:

```bash
sudo apt-get update -y
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo systemctl enable docker
sudo systemctl start docker
```

3. Make script executable and run:

```bash
chmod +x docker-install.sh
./docker-install.sh
```

4. Add Jenkins user to docker group:

```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

## Required Repository Files

### Dockerfile

Create `Dockerfile` in repository root:

```dockerfile
# Use official NGINX base image
FROM nginx:latest

# Set working directory
WORKDIR /usr/share/nginx/html/

# Copy local HTML file to NGINX directory
COPY index.html /usr/share/nginx/html/

# Expose port 80
EXPOSE 80
```

### Sample HTML File

Create `index.html`:

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Pipeline Success</title>
  </head>
  <body>
    <h1>Congratulations!</h1>
    <p>Successfully run first pipeline code.</p>
  </body>
</html>
```

## Pipeline Execution

### Running the Pipeline

1. Commit and push Dockerfile and index.html to repository
2. Pipeline automatically triggers via webhook
3. Monitor execution in Jenkins dashboard

![Pipeline execution](images/pipeline-running.png)

### Accessing Application

1. Configure security group/firewall rules for port 8081

![Security group configuration](images/security-group-8081.png)

2. Access application via browser:

```
http://jenkins-server-ip:8081
```

![Application running](images/app-browser-view.png)

## Troubleshooting

### Common Issues and Solutions

#### Docker Permission Denied

**Problem:** Jenkins cannot execute Docker commands
**Solution:**

```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

#### Port Already in Use

**Problem:** Container fails to start due to port conflict
**Solution:**

```bash
# Find and stop conflicting container
docker ps
docker stop <container-id>
# Or use different port mapping
docker run -itd -p 8082:80 dockerfile
```

#### Dockerfile Not Found

**Problem:** Docker build fails with "cannot find Dockerfile"
**Solution:**

- Ensure Dockerfile exists in repository root
- Check file naming (case-sensitive)
- Verify checkout stage completed successfully

#### GitHub Connection Issues

**Problem:** Pipeline cannot access repository
**Solution:**

- Verify repository URL is correct and accessible
- Check GitHub webhook configuration
- Ensure proper branch name (main vs master)
- Configure Jenkins credentials if repository is private

#### Build Fails After Docker Installation

**Problem:** Jenkins still cannot find Docker commands
**Solution:**

```bash
# Restart Jenkins service
sudo systemctl restart jenkins
# Verify Docker installation
docker --version
# Check Jenkins user can access Docker
sudo -u jenkins docker ps
```

#### Container Stops Immediately

**Problem:** Container exits after starting
**Solution:**

- Check container logs: `docker logs <container-id>`
- Ensure base image runs correctly
- Verify application starts properly in container

#### Pipeline Syntax Errors

**Problem:** Pipeline fails to parse
**Solution:**

- Use Pipeline Syntax generator for complex steps
- Validate Groovy syntax
- Check proper indentation and brackets
- Test pipeline script in smaller segments

### Best Practices

- Always test Dockerfile locally before committing
- Use specific image tags instead of 'latest' for production
- Include error handling in pipeline scripts
- Monitor Jenkins logs for detailed error information
- Clean up unused Docker images and containers regularly
- Use meaningful stage and job names
- Document pipeline changes and configurations

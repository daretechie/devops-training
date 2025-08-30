# Working with Docker Images: Complete DevOps Guide

## Introduction to Docker Images

Docker images serve as the foundation for containers - lightweight, portable packages containing everything needed to run applications. These include code, runtime, libraries, and system tools. Images are built from Dockerfile instructions that define the environment and configuration.

## Pulling Images from Docker Hub

Docker Hub hosts thousands of pre-built images. Access them using the `docker pull` command.

### Searching for Images

```bash
docker search ubuntu
```

![Docker Search Results](image-placeholder-search-results.png)

This command displays available images with official status indicators. Look for "OK" in the OFFICIAL column for organization-supported images.

### Downloading Images

```bash
docker pull ubuntu
```

![Docker Pull Process](image-placeholder-pull-ubuntu.png)

### Viewing Local Images

```bash
docker images
```

![Local Docker Images List](image-placeholder-images-list.png)

This displays all locally stored images with details like size, version, and creation date.

## Creating Dockerfiles

A Dockerfile is a text file containing build instructions for creating custom images. It defines the steps to assemble an application environment.

### Basic Dockerfile Structure

Create a file named `Dockerfile` (no extension):

```dockerfile
# Use the official NGINX base image
FROM nginx:latest

# Set the working directory in the container
WORKDIR /usr/share/nginx/html/

# Copy the local HTML file to the NGINX default public directory
COPY index.html /usr/share/nginx/html/

# Expose port 80 to allow external access
EXPOSE 80

# NGINX image includes default CMD to start the server
```

### Dockerfile Instructions Explained

- **FROM**: Specifies base image from Docker Hub
- **WORKDIR**: Sets working directory inside container
- **COPY**: Transfers files from host to container
- **EXPOSE**: Documents which port the application uses
- **CMD**: Defines default command (NGINX includes this)

### Creating Sample Content

```bash
echo "Welcome to DevOps with Docker" >> index.html
```

## Building Custom Images

Navigate to the directory containing the Dockerfile and build:

```bash
docker build -t my-nginx-app .
```

![Docker Build Process](image-placeholder-build-process.png)

The `-t` flag tags the image with a name, and `.` specifies the current directory as build context.

## Running Containers

### Basic Container Execution

```bash
docker run -p 8080:80 my-nginx-app
```

![Docker Run Command](image-placeholder-run-container.png)

This maps host port 8080 to container port 80.

### Managing Container Lifecycle

List all containers:

```bash
docker ps -a
```

![Container Status](image-placeholder-container-list.png)

Start stopped containers:

```bash
docker start CONTAINER_ID
```

![Starting Container](image-placeholder-start-container.png)

## Security Group Configuration (AWS EC2)

When running containers on EC2, configure security groups to allow traffic:

1. Navigate to EC2 instance security tab
2. Click "Edit inbound rules"
3. Add new rule for port 8080
4. Set source as needed (0.0.0.0/0 for public access)

![Security Group Configuration](image-placeholder-security-group.png)

## Accessing Applications

Open browser and navigate to:

```
http://your-public-ip:8080
```

![Web Application Access](image-placeholder-web-browser.png)

## Pushing Images to Docker Hub

Share custom images by pushing to Docker Hub registry.

### Prerequisites

1. Create Docker Hub account at hub.docker.com
2. Create repository in Docker Hub interface

![Docker Hub Repository](image-placeholder-dockerhub-repo.png)

### Image Tagging

```bash
docker tag my-nginx-app username/repository-name:tag
```

![Docker Tag Command](image-placeholder-tag-image.png)

### Authentication

```bash
docker login -u your-username
```

Enter password when prompted.

![Docker Login](image-placeholder-login.png)

### Pushing Image

```bash
docker push username/repository-name:tag
```

![Docker Push Process](image-placeholder-push-image.png)

### Verification

Check Docker Hub repository to confirm image upload.

![Docker Hub Verification](image-placeholder-hub-verification.png)

## Practical Exercise: Dockerizing Static Web Page

### Step-by-Step Implementation

1. **Launch EC2 Instance**

   - Use Ubuntu AMI
   - Configure security groups for SSH and HTTP access

2. **Install Docker**

   ```bash
   sudo apt update
   sudo apt install docker.io -y
   sudo usermod -aG docker $USER
   ```

3. **Create Project Structure**

   ```bash
   mkdir web-app && cd web-app
   ```

4. **Create HTML File**

   ```bash
   cat > index.html << EOF
   <!DOCTYPE html>
   <html>
   <head><title>Docker Web App</title></head>
   <body><h1>Hello from Docker!</h1></body>
   </html>
   EOF
   ```

5. **Build and Run**
   ```bash
   docker build -t web-app .
   docker run -d -p 8080:80 web-app
   ```

## Troubleshooting Guide

### Common Issues and Solutions

**1. Permission Denied**

```
Error: permission denied while trying to connect to Docker daemon
```

**Solution:** Add user to docker group and restart session

```bash
sudo usermod -aG docker $USER
newgrp docker
```

**2. Port Already in Use**

```
Error: bind: address already in use
```

**Solution:** Use different port or stop conflicting service

```bash
docker run -p 8081:80 my-app
# or
sudo lsof -i :8080
sudo kill -9 PID
```

**3. Image Not Found**

```
Error: Unable to find image 'nginx:latest' locally
```

**Solution:** Pull image explicitly or check internet connection

```bash
docker pull nginx:latest
```

**4. Build Context Issues**

```
Error: COPY failed: no source files were specified
```

**Solution:** Ensure files exist in build context directory

```bash
ls -la
# Verify index.html exists before building
```

**5. Container Exits Immediately**

```
Container stops right after starting
```

**Solution:** Check application logs and ensure proper CMD/ENTRYPOINT

```bash
docker logs container-id
docker run -it image-name /bin/bash
```

**6. Network Connectivity Issues**

```
Cannot access application via browser
```

**Solution:** Verify port mapping and security group rules

```bash
docker port container-name
curl localhost:8080
```

**7. Docker Hub Authentication**

```
Error: authentication required
```

**Solution:** Login with correct credentials

```bash
docker logout
docker login
```

**8. Large Image Sizes**
**Solution:** Use multi-stage builds and alpine base images

```dockerfile
FROM nginx:alpine
# Alpine images are smaller
```

### Best Practices

- Use specific image tags instead of `latest`
- Implement multi-stage builds for production
- Keep images small by removing unnecessary packages
- Use .dockerignore to exclude unwanted files
- Run containers as non-root users when possible
- Regularly update base images for security patches

### Monitoring and Maintenance

```bash
# Check resource usage
docker stats

# Clean up unused images
docker image prune

# Remove stopped containers
docker container prune

# View detailed image information
docker inspect image-name
```

This guide provides a comprehensive foundation for working with Docker images in DevOps environments. Regular practice with these commands and troubleshooting scenarios will build proficiency in containerization workflows.

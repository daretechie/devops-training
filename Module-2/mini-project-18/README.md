# 🐳 Docker and Containers Guide

## 📦 What are Containers?

Containers solve the infamous "it works on my machine" problem that has plagued software development for decades. Before containers, applications would work perfectly in development but fail mysteriously when deployed to different environments due to varying dependencies, configurations, and system differences.

Containers are lightweight, portable packages that encapsulate everything an application needs to run: code, runtime libraries, dependencies, and configuration files. Think of them as standardized shipping containers for software - they ensure applications run consistently across any environment.

![Container Concept Diagram](placeholder-container-concept.png)

## 🚀 Introduction to Docker

Docker, created by Solomon Hykes in 2013, is the leading containerization platform that revolutionized application deployment and management. It provides tools to build, ship, and run containers efficiently.

Docker containers act as isolated environments that share the host operating system's kernel, making them incredibly lightweight compared to traditional virtual machines.

![Docker Logo and Architecture](placeholder-docker-architecture.png)

## ✨ Container Advantages

###  portability Across Environments
Containers package applications with all dependencies, ensuring consistent behavior from development laptops to production servers. No more environment-specific bugs or configuration drift.

### Resource Efficiency vs Virtual Machines
Unlike VMs that require separate operating systems, containers share the host OS kernel. This results in:

- Lower memory usage
- Faster startup times
- Higher density (more containers per host)
- Reduced infrastructure costs

### Rapid Deployment and Scaling
Containers can be started, stopped, and scaled in seconds rather than minutes. This enables:

- Quick response to traffic spikes
- Efficient resource utilization
- Simplified rollbacks and updates

![Docker vs VM Comparison](placeholder-docker-vs-vm.png)

## 🔍 Docker vs Virtual Machines

| Aspect         | Docker Containers           | Virtual Machines                    |
| -------------- | --------------------------- | ----------------------------------- |
| Resource Usage | Lightweight, shares host OS | Heavy, requires full OS per VM      |
| Startup Time   | Seconds                     | Minutes                             |
| Isolation      | Process-level               | Hardware-level                      |
| Performance    | Near-native                 | Some overhead                       |
| Use Case       | Microservices, CI/CD        | Legacy apps, strong isolation needs |

## 🛠️ Prerequisites

Before starting with Docker:

- **Linux Fundamentals**: Comfortable with command-line navigation and basic Linux commands
- **Cloud Computing Basics**: Understanding of servers, networking, and deployment concepts
- **Virtual Machine Concepts**: Knowledge of virtualization and its role in software deployment
- **System Administration**: Basic understanding of package management and system services

## 🎯 Project Goals

- Understand containers and isolation.
- Learn Docker features and commands.
- Deploy and scale applications with Docker.

## ⚡ Installation Guide

### Setting Up Docker on Ubuntu 20.04 LTS

#### Step 1: Prepare the System

```bash
sudo apt-get update
```
*Updates package lists to ensure latest software information*

![Terminal Update Command](placeholder-apt-update.png)

#### Step 2: Install Required Dependencies

```bash
sudo apt-get install ca-certificates curl gnupg
```
*Installs certificate authorities, curl for downloads, and GPG for security verification*

#### Step 3: Create Keyring Directory

```bash
sudo install -m 0755 -d /etc/apt/keyrings
```
*Creates secure directory for storing Docker's authentication keys*

#### Step 4: Add Docker's GPG Key

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```
*Downloads and installs Docker's official GPG key for package verification*

#### Step 5: Set Permissions

```bash
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```
*Ensures the GPG key file is readable by all users*

#### Step 6: Add Docker Repository

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
*Adds Docker's official repository to system package sources*

#### Step 7: Update Package Lists

```bash
sudo apt-get update
```

#### Step 8: Install Docker

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
*Installs Docker Engine and essential components*

![Docker Installation Progress](placeholder-docker-install.png)

#### Step 9: Verify Installation

```bash
sudo systemctl status docker
```
*Checks if Docker service is running properly*

![Docker Service Status](placeholder-docker-status.png)

#### Step 10: Enable Non-Root Access

```bash
sudo usermod -aG docker ubuntu
```
*Adds current user to docker group, allowing Docker commands without sudo*

**Important**: Log out and log back in for group changes to take effect.

## 🐋 Getting Started: Hello World Container

### Running Your First Container

```bash
docker run hello-world
```

![Hello World Container Output](placeholder-hello-world.png)

This command demonstrates Docker's complete workflow:

1.  **Image Check**: Docker searches for `hello-world` image locally
2.  **Image Pull**: Downloads image from Docker Hub if not found locally
3.  **Container Creation**: Creates container instance from image
4.  **Execution**: Runs container and displays greeting message
5.  **Cleanup**: Container stops after completing its task

### Verifying Local Images

```bash
docker images
```
*Lists all images stored locally on the system*

![Docker Images List](placeholder-docker-images.png)

## 🧑‍💻 Essential Docker Commands

### Container Management

#### Running Containers

```bash
# Run container in foreground
docker run nginx

# Run container in background (detached)
docker run -d nginx

# Run container with custom name
docker run --name my-nginx nginx

# Run container with port mapping
docker run -p 8080:80 nginx
```

![Docker Run Examples](placeholder-docker-run.png)

#### Listing Containers

```bash
# Show running containers only
docker ps

# Show all containers (running and stopped)
docker ps -a
```

![Docker PS Output](placeholder-docker-ps.png)

#### Stopping Containers

```bash
# Stop by container ID
docker stop CONTAINER_ID

# Stop by container name
docker stop my-nginx

# Force stop (kill)
docker kill CONTAINER_ID
```

### Image Management

#### Pulling Images

```bash
# Pull latest version
docker pull ubuntu

# Pull specific version
docker pull ubuntu:18.04

# Pull from private registry
docker pull registry.example.com/app:latest
```

#### Pushing Images

```bash
# Login to Docker Hub
docker login

# Tag image for push
docker tag local-image username/repository:tag

# Push to registry
docker push username/repository:tag
```

#### Managing Local Images

```bash
# List all images
docker images

# Remove single image
docker rmi IMAGE_ID

# Remove multiple images
docker rmi IMAGE_ID1 IMAGE_ID2

# Remove unused images
docker image prune
```

![Docker Image Management](placeholder-docker-rmi.png)

## 🔄 Docker Pull vs Run

### `docker pull`

- Downloads an image only.
- Does not start a container.

```bash
docker pull nginx
```

### `docker run`

- Pulls the image if missing.
- Creates and starts a container.

```bash
docker run nginx
```

## 🐞 Troubleshooting Common Issues

### Installation Problems

**Issue**: Permission denied while trying to connect to Docker daemon
`Got permission denied while trying to connect to the Docker daemon socket`

**Solution**:
1.  Add user to docker group: `sudo usermod -aG docker $USER`
2.  Log out and log back in
3.  Restart Docker service: `sudo systemctl restart docker`

---

**Issue**: Docker service fails to start
`Job for docker.service failed because the control process exited with error code`

**Solution**:
1.  Check service status: `sudo systemctl status docker`
2.  Check logs: `sudo journalctl -u docker.service`
3.  Restart service: `sudo systemctl restart docker`
4.  Enable auto-start: `sudo systemctl enable docker`

### Runtime Issues

**Issue**: Container exits immediately
```
docker run ubuntu
# Container starts then stops immediately
```
**Solution**:
Provide a command to keep container running:
```bash
# Run with interactive terminal
docker run -it ubuntu bash

# Run with persistent process
docker run -d ubuntu tail -f /dev/null
```

---

**Issue**: Port already in use
`Error: bind: address already in use`

**Solution**:
1.  Check what's using the port: `sudo lsof -i :8080`
2.  Use different port: `docker run -p 8081:80 nginx`
3.  Stop conflicting service: `sudo systemctl stop apache2`

---

**Issue**: Image not found
`Unable to find image 'myapp:latest' locally`

**Solution**:
1.  Check image name spelling
2.  Verify image exists: `docker search myapp`
3.  Build image if it's custom: `docker build -t myapp .`
4.  Pull from correct registry: `docker pull registry.com/myapp`

### Storage and Cleanup Issues

**Issue**: Running out of disk space
`No space left on device`

**Solution**:
```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# Remove everything unused
docker system prune -a
```

**Issue**: Container data not persisting
`Data disappears when container is removed`

**Solution**: Use volumes for persistent data:
```bash
# Create named volume
docker volume create mydata

# Run with volume mount
docker run -v mydata:/app/data nginx
```

### Network Issues

**Issue**: Cannot access application running in container
`Connection refused when accessing localhost:8080`

**Solution**:
1.  Verify port mapping: `docker ps`
2.  Check correct port binding: `docker run -p 8080:80 nginx`
3.  Test from inside container: `docker exec -it CONTAINER_ID curl localhost:80`

## ✅ Best Practices

### Security
- Always use official images when possible
- Regularly update base images
- Don't run containers as root user
- Use specific image tags instead of `latest`
- Scan images for vulnerabilities

### Performance
- Use multi-stage builds to reduce image size
- Minimize layers in Dockerfiles
- Clean up package caches in same layer
- Use `.dockerignore` to exclude unnecessary files

### Resource Management
- Set memory and CPU limits for containers
- Monitor container resource usage
- Use health checks for container monitoring
- Implement proper logging strategies

## 🚀 Next Steps

After mastering these basics:
1.  **Learn Dockerfile**: Create custom images
2.  **Docker Compose**: Manage multi-container applications
3.  **Container Orchestration**: Explore Kubernetes
4.  **CI/CD Integration**: Automate deployments
5.  **Security Scanning**: Implement vulnerability management
6.  **Monitoring**: Set up container observability

## Quick Reference

| Command         | Purpose                              |
| --------------- | ------------------------------------ |
| `docker run`    | Create and start container           |
| `docker ps`     | List containers                      |
| `docker stop`   | Stop container                       |
| `docker images` | List images                          |
| `docker pull`   | Download image                       |
| `docker push`   | Upload image                         |
| `docker rmi`    | Remove image                         |
| `docker exec`   | Execute command in running container |
| `docker logs`   | View container logs                  |

## 📚 Learning Resources

- [Docker Official Documentation](https://docs.docker.com)
- [Docker Hub](https://hub.docker.com) - Public container registry
- [Play with Docker](https://labs.play-with-docker.com) - Browser-based learning environment

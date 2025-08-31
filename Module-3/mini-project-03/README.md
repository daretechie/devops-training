# Working with Docker Containers

## Introduction to Docker Containers

Docker containers are lightweight, portable, and executable units that encapsulate an application and its dependencies. This guide covers the fundamentals of working with Docker containers, from launching and running containers to managing their complete lifecycle.

**Key Concepts:**

- **Container**: A running instance of a Docker image
- **Image**: A read-only template used to create containers
- **Lifecycle**: The stages a container goes through (created, running, stopped, removed)

## Running Containers

### Basic Container Launch

To run a container, use the `docker run` command followed by the image name:

```bash
docker run ubuntu
```

![Docker Run Command](placeholder-docker-run-ubuntu.png)
_Basic docker run command creating an Ubuntu container_

**Note**: This creates a container but it may exit immediately since Ubuntu has no default command to keep it running.

### Starting an Existing Container

If a container exists but is stopped, start it using:

```bash
docker start CONTAINER_ID
```

![Docker Start Command](placeholder-docker-start.png)
_Starting a stopped container by its ID_

## Container Launch Options

### Environment Variables

Set environment variables within containers:

```bash
docker run -e "MY_VARIABLE=my-value" ubuntu
```

### Running in Background (Detached Mode)

Run containers in the background using the `-d` flag:

```bash
docker run -d ubuntu
```

![Docker Detached Mode](placeholder-docker-detached.png)
_Container running in detached mode_

### Interactive Mode

For interactive sessions, combine `-i` (interactive) and `-t` (pseudo-TTY):

```bash
docker run -it ubuntu /bin/bash
```

This opens a shell session inside the container.

## Container Lifecycle Management

### Starting Containers

Start a stopped container:

```bash
docker start container_name
```

### Stopping Containers

Stop a running container gracefully:

```bash
docker stop container_name
```

![Docker Stop Command](placeholder-docker-stop.png)
_Stopping a running container_

### Restarting Containers

Restart a container (stops and starts):

```bash
docker restart container_name
```

### Checking Container Status

View all containers (running and stopped):

```bash
docker ps -a
```

View only running containers:

```bash
docker ps
```

![Docker PS Output](placeholder-docker-ps.png)
_Container status listing with docker ps_

## Removing Containers

### Remove a Single Container

Remove a stopped container:

```bash
docker rm container_name
```

### Force Remove a Running Container

Remove a running container forcefully:

```bash
docker rm -f container_name
```

### Remove All Stopped Containers

Clean up all stopped containers:

```bash
docker container prune
```

![Docker Remove Container](placeholder-docker-rm.png)
_Removing containers and cleanup_

## Common Troubleshooting

### Issue: Container Exits Immediately

**Problem**: Container starts but exits right away
**Solution**: Ubuntu containers need a command to keep running

```bash
# Instead of: docker run ubuntu
# Use:
docker run -it ubuntu /bin/bash
# Or for background:
docker run -d ubuntu sleep infinity
```

### Issue: "Container Already Exists" Error

**Problem**: Trying to run with same name
**Solution**: Remove existing container or use different name

```bash
docker rm container_name
# Or use auto-generated names
docker run ubuntu
```

### Issue: Cannot Stop Container

**Problem**: Container won't stop with `docker stop`
**Solution**: Force kill the container

```bash
docker kill container_name
```

### Issue: Out of Disk Space

**Problem**: Too many containers consuming space
**Solution**: Clean up unused containers and images

```bash
docker system prune -a
```

### Issue: Permission Denied

**Problem**: Cannot run docker commands
**Solution**: Add user to docker group or use sudo

```bash
sudo usermod -aG docker $USER
# Then logout and login again
```

## Best Practices

### Naming Conventions

Always name containers for easier management:

```bash
docker run --name my-ubuntu-container ubuntu
```

### Resource Management

Monitor container resource usage:

```bash
docker stats
```

### Logging

Check container logs for debugging:

```bash
docker logs container_name
```

## Practical Exercise: Docker Container Operations

### Task 1: Start Container and Run Commands

1. Pull Ubuntu image (if not available):

   ```bash
   docker pull ubuntu
   ```

2. Start interactive container:

   ```bash
   docker run -it --name practice-ubuntu ubuntu /bin/bash
   ```

3. Inside container, run system information command:
   ```bash
   uname -a
   cat /etc/os-release
   ```

### Task 2: Stop and Verify Status

1. Exit the container:

   ```bash
   exit
   ```

2. Stop the container:

   ```bash
   docker stop practice-ubuntu
   ```

3. Verify status:
   ```bash
   docker ps -a
   ```
   Check the STATUS column shows "Exited"

### Task 3: Restart and Observe

1. Restart the container:

   ```bash
   docker restart practice-ubuntu
   ```

2. Verify it's running:

   ```bash
   docker ps
   ```

3. Attach to running container:
   ```bash
   docker exec -it practice-ubuntu /bin/bash
   ```

### Task 4: Remove Container

1. Stop the container:

   ```bash
   docker stop practice-ubuntu
   ```

2. Remove the container:

   ```bash
   docker rm practice-ubuntu
   ```

3. Verify removal:
   ```bash
   docker ps -a
   ```
   The container should no longer appear in the list.

## Quick Reference Commands

| Operation         | Command                         | Description                      |
| ----------------- | ------------------------------- | -------------------------------- |
| Run container     | `docker run image`              | Create and start new container   |
| Run detached      | `docker run -d image`           | Run container in background      |
| Run interactive   | `docker run -it image`          | Run with interactive terminal    |
| List containers   | `docker ps -a`                  | Show all containers              |
| Start container   | `docker start container`        | Start stopped container          |
| Stop container    | `docker stop container`         | Stop running container           |
| Restart container | `docker restart container`      | Restart container                |
| Remove container  | `docker rm container`           | Delete container                 |
| View logs         | `docker logs container`         | Show container logs              |
| Execute command   | `docker exec -it container cmd` | Run command in running container |

Understanding these container fundamentals provides the foundation for effective Docker usage in development and deployment workflows. Master these basics before moving to more advanced topics like container networking and orchestration.

# 🐳 Working with Docker Containers

Docker containers are lightweight, portable, and executable units that package applications and their dependencies. Containers can be created, started, stopped, restarted, and removed as needed. Mastering container lifecycle operations is key in DevOps workflows.

---

## ▶️ Running Containers

Run a container from an image:

```bash
docker run ubuntu
```

📷 _\[Screenshot: docker run ubuntu output]_

If the container exits immediately, it means no process is running inside. Start it again with:

```bash
docker start <CONTAINER_ID>
```

📷 _\[Screenshot: docker start output]_

---

## ⚙️ Launching Containers with Options

Set environment variables:

```bash
docker run -e "MY_VARIABLE=my-value" ubuntu
```

📷 _\[Screenshot: container with environment variable]_

Run in the background (detached mode):

```bash
docker run -d ubuntu
```

📷 _\[Screenshot: detached container running]_

Map ports (example with nginx):

```bash
docker run -d -p 8080:80 nginx
```

📷 _\[Screenshot: nginx container running on port 8080]_

Mount a local volume:

```bash
docker run -v /host/path:/container/path ubuntu
```

📷 _\[Screenshot: container with mounted volume]_

---

## 🔄 Container Lifecycle

Containers can be created once and reused many times.

- **Start a container:**

```bash
docker start <container_name>
```

- **Stop a container:**

```bash
docker stop <container_name>
```

- **Restart a container:**

```bash
docker restart <container_name>
```

📷 _\[Screenshot: docker ps showing container states]_

---

## ❌ Removing Containers

Delete a container:

```bash
docker rm <container_name>
```

📷 _\[Screenshot: docker rm output]_

Delete all stopped containers:

```bash
docker container prune -f
```

---

## 🧑‍💻 Side Hustle Task: Docker Container Operations

1. **Start a Container & Run Command**

   - Run Ubuntu and execute:

   ```bash
   docker run ubuntu uname -a
   ```

   📷 _\[Screenshot: system info inside container]_

2. **Stop Container & Verify Status**

   ```bash
   docker stop <CONTAINER_ID>
   docker ps -a
   ```

   📷 _\[Screenshot: container status stopped]_

3. **Restart Container & Observe**

   ```bash
   docker restart <CONTAINER_ID>
   docker ps
   ```

   📷 _\[Screenshot: container running again]_

4. **Remove Container**

   ```bash
   docker stop <CONTAINER_ID>
   docker rm <CONTAINER_ID>
   docker ps -a
   ```

   📷 _\[Screenshot: container removed confirmation]_

---

## 🐞 Troubleshooting

| Issue                                     | Cause                             | Solution                                                 |
| ----------------------------------------- | --------------------------------- | -------------------------------------------------------- |
| Container exits immediately               | No command specified              | Run with interactive shell: `docker run -it ubuntu bash` |
| `port already in use`                     | Another process is using the port | Use a different mapping: `-p 8081:80`                    |
| `cannot start container`                  | Container already running         | Stop it first: `docker stop <id>`                        |
| `conflict: container name already in use` | Duplicate name used               | Remove old container or run with `--name new_name`       |

---

## ✅ Final Notes

- Use `docker ps -a` to track container lifecycle.
- Detached mode (`-d`) is useful for background services.
- Always clean up unused containers with `docker container prune`.
- Mastering container lifecycle management lays the foundation for orchestration tools like Kubernetes.

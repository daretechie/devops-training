# 🐳 Working with the Docker Container Lifecycle

This guide covers the fundamentals of working with Docker containers, from launching and running them to managing their complete lifecycle. Mastering these operations is a key skill in modern DevOps workflows.

---

## 🎯 Core Concepts

- **Image**: A read-only template used to create containers.
- **Container**: A runnable instance of a Docker image. It is a lightweight, portable, and executable unit that packages an application and its dependencies.
- **Lifecycle**: The stages a container goes through: created, running, stopped, and removed.

---

## ▶️ Running and Managing Containers

### Basic Container Launch

To run a container from an image, use the `docker run` command. If the image is not available locally, Docker will pull it from the registry.

```bash
# This container will run, print its kernel info, and then exit.
docker run ubuntu uname -a
```

### Interactive Mode

For an interactive shell session inside a container, use the `-i` (interactive) and `-t` (pseudo-TTY) flags.

```bash
docker run -it ubuntu /bin/bash
```
This opens a bash shell inside the Ubuntu container, allowing you to run commands directly within it.

### Detached Mode

To run a container in the background, use the `-d` (detached) flag. This is useful for long-running services like web servers.

```bash
# The 'sleep infinity' command keeps the container running in the background.
docker run -d ubuntu sleep infinity
```

### Naming a Container

It is a best practice to assign names to your containers for easier management.

```bash
docker run -d --name my-ubuntu-container ubuntu sleep infinity
```

---

## 🔄 Container Lifecycle Management

Use the following commands to manage the state of your containers.

### Listing Containers

- **View only running containers:**
  ```bash
  docker ps
  ```
- **View all containers (running and stopped):**
  ```bash
  docker ps -a
  ```

### Starting, Stopping, and Restarting

- **Start a stopped container:**
  ```bash
  docker start <container_name_or_id>
  ```
- **Stop a running container gracefully:**
  ```bash
  docker stop <container_name_or_id>
  ```
- **Restart a container:**
  ```bash
  docker restart <container_name_or_id>
  ```

### Executing Commands in a Running Container

You can run commands inside a running container without attaching a full terminal session using `docker exec`.

```bash
# Execute 'echo' command inside 'my-ubuntu-container'
docker exec my-ubuntu-container echo "Hello from inside the container"
```

### Removing Containers

- **Remove a stopped container:**
  ```bash
  docker rm <container_name_or_id>
  ```
- **Force-remove a running container:**
  ```bash
  docker rm -f <container_name_or_id>
  ```
- **Remove all stopped containers (pruning):**
  ```bash
  docker container prune -f
  ```

---

## ✍️ Practical Exercise: Docker Container Operations

This exercise will walk you through the complete lifecycle of a container.

### Task 1: Create and Run an Interactive Container

1.  Pull the latest `ubuntu` image to ensure you have it locally.
    ```bash
    docker pull ubuntu
    ```
2.  Start an interactive container and name it `practice-ubuntu`.
    ```bash
    docker run -it --name practice-ubuntu ubuntu /bin/bash
    ```
3.  Inside the container's shell, run a command to see the OS release information, then exit.
    ```bash
    cat /etc/os-release
    exit
    ```

### Task 2: Verify Status and Restart the Container

1.  After exiting, the container is stopped. Verify its status is "Exited".
    ```bash
    docker ps -a
    ```
2.  Restart the container. It will run in the background because its original command was `/bin/bash`.
    ```bash
    docker restart practice-ubuntu
    ```
3.  Verify that it is now running.
    ```bash
    docker ps
    ```

### Task 3: Execute a Command and View Logs

1.  Execute a command inside the running `practice-ubuntu` container.
    ```bash
    docker exec practice-ubuntu ls -la /
    ```
2.  View the logs for the container (in this case, there won't be many).
    ```bash
    docker logs practice-ubuntu
    ```

### Task 4: Stop and Remove the Container

1.  Stop the container.
    ```bash
    docker stop practice-ubuntu
    ```
2.  Remove the container.
    ```bash
    docker rm practice-ubuntu
    ```
3.  Verify it has been removed by listing all containers. It should no longer appear.
    ```bash
    docker ps -a
    ```

---

## 🐞 Common Troubleshooting

| Issue | Cause | Solution |
| :--- | :--- | :--- |
| **Container exits immediately** | The container's main process finished. | Run it with a long-running command (`sleep infinity`) or in interactive mode (`-it`). |
| **`port already in use`** | Another process is using the host port. | Stop the other process or use a different host port (`-p 8081:80`). |
| **`container name already in use`** | A container with that name already exists. | Remove the old container (`docker rm <name>`) or choose a new name. |
| **`Permission denied`** | The current user is not in the `docker` group. | Add your user to the `docker` group: `sudo usermod -aG docker $USER` (requires logout/login). |

---

## ✨ Best Practices

- **Naming:** Always name your containers (`--name`) for easy reference.
- **Cleanup:** Regularly clean up unused containers (`docker container prune`) and images (`docker image prune`) to save disk space.
- **Resource Monitoring:** Use `docker stats` to monitor the resource (CPU, Memory) usage of your running containers.
- **Logging:** Check container logs with `docker logs <container_name>` for debugging.
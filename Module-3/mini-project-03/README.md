# 🐳 Working with Docker Containers

Docker containers are lightweight, portable, and executable units that encapsulate an application and its dependencies. This guide covers the fundamentals of working with Docker containers, from launching and running them to managing their complete lifecycle.

**Key Concepts:**

*   **Image**: A read-only template used to create containers.
*   **Container**: A running instance of a Docker image.
*   **Lifecycle**: The stages a container goes through (created, running, stopped, removed).

---

## ▶️ Running Containers

### Basic Container Launch

To run a container, use the `docker run` command followed by the image name. This creates and starts the container.

```bash
docker run ubuntu
```

**Note**: A simple `docker run ubuntu` command will cause the container to exit immediately because no long-running process is active. To keep it running, you need to specify a command (see Interactive Mode).

### Starting an Existing Container

If a container is stopped, you can restart it using its name or ID:

```bash
docker start my-ubuntu-container
```

---

## ⚙️ Launching Containers with Options

You can customize container launch with various flags:

*   **Naming a Container (`--name`)**: Assign a memorable name.
    ```bash
    docker run --name my-ubuntu-container ubuntu
    ```

*   **Detached Mode (`-d`)**: Run the container in the background.
    ```bash
    docker run -d --name my-bg-process ubuntu sleep infinity
    ```

*   **Interactive Mode (`-it`)**: Open an interactive shell inside the container.
    ```bash
    docker run -it --name my-interactive-shell ubuntu /bin/bash
    ```

*   **Environment Variables (`-e`)**: Set environment variables.
    ```bash
    docker run -e "MY_VARIABLE=my-value" ubuntu
    ```

*   **Port Mapping (`-p`)**: Map a host port to a container port.
    ```bash
    docker run -d -p 8080:80 --name my-web-server nginx
    ```

*   **Volume Mounting (`-v`)**: Mount a local directory into the container.
    ```bash
    docker run -v /host/path:/container/path ubuntu
    ```

---

## 🔄 Container Lifecycle Management

| Operation         | Command                         | Description                               |
| ----------------- | ------------------------------- | ----------------------------------------- |
| List Running      | `docker ps`                     | Show running containers                   |
| List All          | `docker ps -a`                  | Show all containers (running and stopped) |
| Start             | `docker start <container>`      | Start a stopped container                 |
| Stop              | `docker stop <container>`       | Stop a running container gracefully       |
| Restart           | `docker restart <container>`    | Restart a container                       |
| View Logs         | `docker logs <container>`       | Show container logs                       |
| Inspect           | `docker inspect <container>`    | Display low-level information             |
| Execute Command   | `docker exec -it <container> cmd` | Run a command in a running container      |

---

## ❌ Removing Containers

Remove a stopped container by its name or ID:

```bash
docker rm my-container
```

To force-remove a running container, use the `-f` flag:

```bash
docker rm -f my-container
```

To remove all stopped containers at once:

```bash
docker container prune
```

---

## 🧑‍💻 Practical Exercise: Docker Container Operations

1.  **Start an Interactive Container**
    Run an Ubuntu container, give it a name, and open a `bash` shell.
    ```bash
    docker run -it --name practice-ubuntu ubuntu /bin/bash
    ```

2.  **Run Commands Inside the Container**
    Check the operating system release.
    ```bash
    cat /etc/os-release
    exit
    ```

3.  **Check Container Status**
    Verify that the container has exited.
    ```bash
    docker ps -a
    ```

4.  **Restart and Re-attach**
    Start the container again and attach to it with `exec`.
    ```bash
    docker start practice-ubuntu
    docker exec -it practice-ubuntu /bin/bash
    ```

5.  **Clean Up**
    Stop and remove the container.
    ```bash
    docker stop practice-ubuntu
    docker rm practice-ubuntu
    ```

---

## 🐞 Troubleshooting

| Issue                                     | Cause                             | Solution                                                    |
| ----------------------------------------- | --------------------------------- | ----------------------------------------------------------- |
| Container exits immediately               | No foreground process is running  | Use `-it` for a shell or `-d` with a long-running command.  |
| `port already in use`                     | Another process is using the port | Stop the other process or use a different host port.        |
| `conflict: container name already in use` | A container with that name exists | Use a different name or remove the old container first.     |
| `permission denied`                       | Docker daemon requires `sudo`     | Add your user to the `docker` group or run commands with `sudo`. |

---

## ✅ Best Practices

*   **Name Your Containers**: Use the `--name` flag to assign meaningful names for easier management.
*   **Clean Up Regularly**: Use `docker container prune` to remove stopped containers and `docker image prune` for unused images to save disk space.
*   **Use Specific Image Versions**: Instead of `ubuntu`, use a specific tag like `ubuntu:22.04` for reproducible builds.
*   **Monitor Resources**: Use `docker stats` to monitor the CPU, memory, and network usage of your running containers.

Mastering these fundamentals is the first step toward effective container management and orchestration with tools like Docker Compose and Kubernetes.

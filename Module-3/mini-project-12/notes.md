Setting up Minikube
Container Orchestration With Kubernetes
Imagine orchestrating a vibrant culinary event with various chefs preparing different dishes. Container orchestration, seamlessly coordinates each chef (container) to ensure the perfect serving, timing, and overall dining experience. Just as a skilled event planner brings order to chaos, Kubernetes, a notable orchestrator, orchestrates containers, making it the go-to choice for managing the intricate dance of modern applications. Container orchestration is a critical aspect of managing and scaling containerized applications efficiently. It involves automating the deployment, scaling, and operation of containerized applications, ensuring seamless coordination among multiple containers to deliver high availability and optimal performance. One widely used container orchestration tool is Kubernetes. Developed by Google, Kubernetes has become the de facto standard for automating the deployment, scaling, and management of containerized applications.

What is Kubernetes ?
Kubernetes is an open-source container orchestration platform that automates the deployment, scaling, and management of containerized applications. Developed by Google and later open-sourced. Kubernetes is widely adopted for its ability to streamline and automate the deployment, scaling, and management of containerized applications in a highly efficient and consistent manner. It provides a centralized platform that abstracts away the complexities of distributed systems, offering features such as automated load balancing, self-healing capabilities, and seamless rolling updates.

Componentes Of A Kubernetes Cluster
Kubernetes Architecture

Control Plane or Master Node: The Control Plane, often referred to as the master node, is the brain of a Kubernetes cluster. It manages the entire cluster, making high-level decisions about the state of the system. Components like the API Server, Scheduler, Controller Manager, and etcd (key-value store for cluster data) constitute the Control Plane.

Nodes: Nodes are individual machines within a Kubernetes cluster responsible for running containerized applications. Each node is equipped with a container runtime (e.g., Docker), a kubelet (communicates with the master and manages containers on the node), and a kube-proxy (maintains network rules). Nodes execute and manage containers, distribute workloads, and communicate with the control plane to maintain the desired state of the system. The collaboration of multiple nodes creates a scalable and resilient environment, forming the foundation for deploying and orchestrating containerized applications in Kubernetes.

Pods: Pods are the fundamental deployment units in Kubernetes, representing one or more closely related containers that share the same network namespace, storage, and set of specifications. Containers within a Pod work together and are scheduled to run on the same node. Pods encapsulate the basic building blocks for deploying and scaling applications, fostering tight communication between co-located containers.

Containers: Containers in Kubernetes encapsulate and package applications, along with their dependencies and runtime environment, ensuring consistency across various computing environments. Leveraging containerization technology, such as Docker, containers provide a lightweight, portable, and efficient way to deploy and run applications. In Kubernetes, containers are organized into Pods, the smallest deployable units.

Kubernetes Architecture

API Server: The API Server is the control plane component in Kubernetes that serves as the front end for the Kubernetes control plane. It exposes the Kubernetes API, allowing users, other components, and external entities to interact with the cluster, managing resources, and initiating various actions.

Controller Manager: The Controller Manager is a control plane component in Kubernetes responsible for maintaining the desired state of the cluster. It includes various controllers that watch the state of the cluster through the API Server and take corrective actions to ensure that the actual state aligns with the desired state.

Scheduler: The Scheduler is a control plane component in Kubernetes that assigns workloads to nodes in the cluster based on resource requirements, constraints, and availability. It plays a crucial role in distributing workloads evenly and efficiently across the worker nodes, optimizing resource utilization.

etcd: etcd is a distributed key-value store that acts as the cluster's single source of truth for all persistent cluster data. In Kubernetes, etcd is used to store configuration details, state information, and metadata, providing a reliable and consistent data store that ensures the integrity of the cluster's information.

Kubelet: The Kubelet is a vital component in Kubernetes running on each node in the cluster. It communicates with the Kubernetes control plane, specifically the API Server, to ensure that containers are running in a Pod as expected. Kubelet plays a key role in managing the containers on a node, handling tasks such as starting, stopping, and monitoring container processes based on the specifications received from the control plane.

Kube Proxy: Kube Proxy, or Kubernetes Proxy, is responsible for maintaining network rules on nodes. It enables communication between Pods and external entities, handling network routing and ensuring that the correct network policies are applied.

Project Prerequisites
Completion of foundations core program 1 & 2 projects
2 CPUs or more
2GB of free memory
20GB of free disk space
Project Goals
By the end of this project, learners should have:

Gained a comprehensive understanding of Kubernetes and its fundamental concepts.
Mastered the usage of Minikube for local Kubernetes cluster deployment and experimentation.
Acquired hands-on experience with Docker, understanding containerization principles and how to create, manage, and distribute containerized applications.
Built and deployed applications on minikube
Minikube
Now that we have an idea of what kubernetes is, let's set up a minikube. But what is minikube ?

Minikube is an open-source tool that enables us to run Kubernetes clusters locally our machines.As we now know that kubernetes is a container orchestration platform that automates the deployment, scaling, and management of containerized applications. Minikube streamlines the creation of a local Kubernetes environment, providing a user-friendly playground where we can safely build and test their applications before deploying them to a production setting.

Let's get started with setting up minikube.

Getting Started With Minikube
Installing Minikube on Windows
To install minikube on windows, we need to use chocolatey. Chocolatey, just like linux apt and yum, is a windows package manager for installing, updating and removing software packages on windows.

i. Go to the windows search bar and launch a terminal with administrative access

Alt text

ii. Install Minikube

Copy
choco install minikube
Alt text

Note: If you don't have chocolatey installed, follow the official documentation to install it.

iii. Minikube needs docker as a driver and also to pull it's base image, therefore we need to install docker desktop for windows.

Go to docker desktop official documentation to install it if not installed

iv. Run the command below to start minikube using docker as the driver

Copy
minikube start --driver=docker
Alt text

Installing Minikube on Linux
For linux users, let's install minikube

i. Launch a terminal with administrative access

ii. We need to install docker as a driver for minikube and also for minikube to pull base images for the kubernetes cluster

Copy
sudo apt-get update
This a Linux command that refreshes the package list on a Debian-based system, ensuring the latest software information is available for installation.

Copy
sudo apt-get install ca-certificates curl gnupg
This a Linux command that installs essential packages including certificate authorities, a data transfer tool (curl), and the GNU Privacy Guard for secure communication and package verification.

Copy
sudo install -m 0755 -d /etc/apt/keyrings
The command above creates a directory (/etc/apt/keyrings) with specific permissions (0755) for storing keyring files, which are used for docker's authentication

Copy
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
This downloads the Docker GPG key using curl

Copy
sudo chmod a+r /etc/apt/keyrings/docker.gpg
Sets read permissions for all users on the Docker GPG key file within the APT keyring directory

Let's add the repository to Apt sources

Copy
echo \
 "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
 $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
 sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
The "echo" command creates a Docker APT repository configuration entry for the Ubuntu system, incorporating the system architecture and Docker GPG key, and then "sudo tee /etc/apt/sources.list.d/docker.list > /dev/null" writes this configuration to the "/etc/apt/sources.list.d/docker.list" file.

Copy
sudo apt-get update
Install latest version of docker

Copy
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
Verify that docker has been successfully installed

Copy
sudo systemctl status docker
Alt text

iii. Install minikube

Copy
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
If you get an error after running the command above, reach out to the technical support.

Copy
sudo dpkg -i minikube_latest_amd64.deb
The command above downloads minikube's binary and install minikube using dpkg

Alt text

iv. Start minikube

Copy
minikube start --driver=docker
Alt text

v. Kubectl is the command-line interface (CLI) tool for interacting with and managing Kubernetes clusters, allowing users to deploy, inspect, and manage applications within the Kubernetes environment. Let's install kubectl

Copy
sudo snap install kubectl --classic
This will download the kubernetes command line (kubectl) tool to interact with kubernetes cluster

Alt text

Installing Minikube on mac
For mac users, let's install minikube

i. Launch a terminal with administrative access

ii. Install minikube

Copy
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64

Copy
sudo install minikube-darwin-amd64 /usr/local/bin/minikube

The command above downloads minikube's binary and install minikube.

iv. Just like windows and linux, we need docker desktop as a driver for minikube. TO install docker desktop for mac go to docker desktop official documentation to install it if not installed

v. Run the command below to start minikube using virtualbox as the driver

Copy
minikube start --driver=docker

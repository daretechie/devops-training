# Managing Kubernetes Pods with Minikube

This project provides a comprehensive, beginner-friendly guide to managing Kubernetes Pods. As the fundamental building blocks of Kubernetes applications, understanding Pods is a critical first step. This document details the process of listing, inspecting, creating, and deleting Pods within a local Minikube environment.

## Table of Contents

- [Project Overview](#project-overview)
- [Prerequisites](#prerequisites)
- [Core Concepts: Pods and Containers](#core-concepts-pods-and-containers)
  - [What is a Kubernetes Pod?](#what-is-a-kubernetes-pod)
  - [What is a Container?](#what-is-a-container)
- [Part 1: Observing System Pods](#part-1-observing-system-pods)
  - [Step 1: List All Pods in the Cluster](#step-1-list-all-pods-in-the-cluster)
  - [Step 2: Inspect a System Pod](#step-2-inspect-a-system-pod)
- [Part 2: Creating and Managing a Custom Pod](#part-2-creating-and-managing-a-custom-pod)
  - [Step 3: Define a Pod with a YAML Manifest](#step-3-define-a-pod-with-a-yaml-manifest)
  - [Step 4: Deploy the Pod from the Manifest](#step-4-deploy-the-pod-from-the-manifest)
  - [Step 5: Verify and Inspect the New Pod](#step-5-verify-and-inspect-the-new-pod)
  - [Step 6: Clean Up by Deleting the Pod](#step-6-clean-up-by-deleting-the-pod)
- [Troubleshooting Common Pod Issues](#troubleshooting-common-pod-issues)
- [Key Takeaways](#key-takeaways)
- [Further Exploration: Multi-Container Pods](#further-exploration-multi-container-pods)

## Project Overview

By completing this project, you will gain hands-on experience with `kubectl` to perform essential Pod management tasks. The key objectives are to:

- Understand the relationship between Pods and Containers.
- Use `kubectl` to list and inspect Pods across all namespaces.
- Define and create a Pod using a YAML manifest file.
- Verify the status of a deployed Pod.
- Delete a Pod to clean up resources.

## Prerequisites

- **Minikube:** A running Minikube cluster is required.
- **kubectl:** The Kubernetes command-line tool, configured to communicate with your Minikube cluster.

## Core Concepts: Pods and Containers

### What is a Kubernetes Pod?

A **Pod** is the smallest deployable unit of computing that you can create and manage in Kubernetes. It acts as a wrapper for one or more containers, providing a shared execution environment. Containers within the same Pod share resources, including:

- **Network:** They communicate with each other over `localhost`.
- **Storage:** They can share storage volumes.

A Pod represents a single instance of an application and is considered an ephemeral, disposable entity.

### What is a Container?

A **Container** is a lightweight, standalone, executable package that includes everything needed to run a piece of software: code, runtime, libraries, and system tools. Containers are the core technology inside Pods. Kubernetes orchestrates these containers, ensuring they run reliably and consistently across different environments.

## Part 1: Observing System Pods

Your Minikube cluster runs several system Pods to manage itself. Let's start by observing them.

### Step 1: List All Pods in the Cluster

To see all Pods running in every namespace, use the `kubectl get pods -A` command. This provides a complete overview of your cluster's workload.

```bash
kubectl get pods -A
```

**Demonstration of Listing All Pods:**
![Listing all pods across all namespaces](img/list-all-pods.png)

### Step 2: Inspect a System Pod

To get detailed information about a specific Pod, use `kubectl describe pod`. Let's inspect the `kube-scheduler` Pod, which is a critical component of the Kubernetes control plane.

```bash
# Note: Your pod name might differ slightly. Use the name from the previous command's output.
kubectl describe pod kube-scheduler-minikube -n kube-system
```

This command reveals the Pod's current state, recent events, container details, and configuration.

**Demonstration of Inspecting the Kube-Scheduler Pod:**
![Inspecting the kube-scheduler pod](img/describe-pod.png)

## Part 2: Creating and Managing a Custom Pod

Now, we will define and deploy our own application Pod running an Nginx web server.

### Step 3: Define a Pod with a YAML Manifest

Kubernetes objects are defined declaratively in YAML files. Create a file named `pod.yaml` with the following content.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-first-pod
spec:
  containers:
    - name: nginx
      image: nginx:latest # Corrected from 'lastest' to 'latest'
      ports:
        - containerPort: 80
```

This manifest tells Kubernetes to create a Pod named `my-first-pod` with a single container using the official `nginx:latest` image.

### Step 4: Deploy the Pod from the Manifest

Use `kubectl apply -f` to instruct Kubernetes to create the resources defined in your YAML file.

```bash
kubectl apply -f pod.yaml
```

**Demonstration of Applying the Pod Manifest:**
![Creating the my-first-pod](img/create-pod.png)

### Step 5: Verify and Inspect the New Pod

After applying the manifest, verify that the Pod was created successfully and is in the `Running` state.

```bash
kubectl get pods
```

Once running, inspect it to confirm its configuration.

```bash
kubectl describe pod my-first-pod
```

**Demonstration of Verifying the New Pod:**
![Verifying and inspecting the new pod](img/verify-pod.png)

### Step 6: Clean Up by Deleting the Pod

Always clean up resources you create. You can delete the Pod using its name or the file that created it.

```bash
# Option 1: Delete by Pod name
kubectl delete pod my-first-pod

# Option 2: Delete using the manifest file
kubectl delete -f pod.yaml
```

**Demonstration of Deleting the Pod:**
![Deleting the pod](img/delete-pod.png)

## Troubleshooting Common Pod Issues

| Problem | Cause | Solution |
| :--- | :--- | :--- |
| **Pod is `Pending`** | The scheduler cannot assign the Pod to a Node. This is often due to insufficient CPU or memory resources. | Use `kubectl describe pod <pod-name>` to check the "Events" section for messages from the scheduler. |
| **Pod is `ImagePullBackOff`** | Kubernetes failed to pull the container image from the registry. | Check for typos in the image name or tag (e.g., `nginx:lastest` instead of `nginx:latest`). Verify that the image exists and that your cluster has network access to the registry. |
| **Pod is `CrashLoopBackOff`** | The container starts but exits with an error, causing Kubernetes to restart it repeatedly. | Use `kubectl logs <pod-name>` to view the container's logs and identify the application-level error causing the crash. |

## Key Takeaways

- **Declarative Management:** Kubernetes operates on a declarative model. You define the *desired state* in a YAML file, and Kubernetes works to achieve and maintain that state.
- **Pods as the Atomic Unit:** Pods are the smallest deployable units in Kubernetes. All containers within a Pod are scheduled together on the same Node.
- **`kubectl` is Essential:** The `kubectl` CLI is the primary tool for interacting with a Kubernetes cluster. Key commands include `get`, `describe`, `apply`, and `delete`.
- **Troubleshooting is Key:** Understanding how to use `describe` and `logs` is crucial for diagnosing and resolving issues with Pods and applications.

## Further Exploration: Multi-Container Pods

While this project focused on a single-container Pod, a common pattern is to use multiple containers in one Pod. This is useful when two applications need to work closely together. For example:

- A web server container that serves files.
- A "sidecar" container that pulls the latest files from a Git repository.

Because they are in the same Pod, they can easily share a storage volume. This pattern allows you to build modular, reusable components.
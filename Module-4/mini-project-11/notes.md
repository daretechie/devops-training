Setup Prometheus Node Exporter on Kubernetes
Introduction
Prometheus is a widely-used monitoring system that collects and processes metrics from various sources. The Node Exporter is a Prometheus exporter that collects hardware and operating system metrics from a system. By deploying Node Exporter on Kubernetes, you can monitor the nodes in your Kubernetes cluster and gain insights into their performance.

Objectives
Understand the purpose of Prometheus Node Exporter.
Deploy Node Exporter as a DaemonSet in a Kubernetes cluster.
Configure Prometheus to scrape metrics from Node Exporter.
Visualize metrics using Prometheus UI.
Explore metrics available through Node Exporter.
Prerequisites
Kubernetes Cluster: A working Kubernetes cluster (e.g., Minikube, Kind, or a managed kubernetes service like EKS or AKS or GKE).
Kubernetes CLI: kubectl installed and configured for your cluster.
Prometheus Setup: Basic Prometheus installation running in the Kubernetes cluster.
Tools: A text editor to modify YAML files.
Estimated Time
2-4 hours.

Tasks Outline
Understand how Node Exporter works and its purpose.
Deploy Node Exporter as a DaemonSet.
Configure Prometheus to scrape metrics from Node Exporter.
Verify the metrics in Prometheus.
Explore the metrics provided by Node Exporter.
Project Tasks
Task 1 - Understand How Node Exporter Works
Node Exporter is a lightweight application that runs on a node and exposes metrics about the node’s hardware and operating system.
Key metrics include:
CPU and memory usage
Disk I/O
Network statistics
Filesystem usage
Node Exporter runs as a containerized application in Kubernetes to collect metrics from each node.
Task 2 - Deploy Node Exporter as a DaemonSet
Create a YAML file for the Node Exporter DaemonSet:


Copy
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      containers:
        - name: node-exporter
          image: prom/node-exporter:latest
          ports:
            - containerPort: 9100
              name: metrics
          securityContext:
            runAsNonRoot: true
            allowPrivilegeEscalation: false
          resources:
            limits:
              memory: "100Mi"
              cpu: "100m"
            requests:
              memory: "50Mi"
              cpu: "50m"
Apply the YAML file using kubectl:


Copy
kubectl apply -f node-exporter-daemonset.yaml
Verify the deployment:


Copy
kubectl get daemonset -n monitoring
Task 3 - Configure Prometheus to Scrape Metrics from Node Exporter
Edit the Prometheus configuration to add a scrape job for Node Exporter:


Copy
scrape_configs:
  - job_name: 'node-exporter'
    kubernetes_sd_configs:
      - role: endpoints
    relabel_configs:
      - source_labels: [__meta_kubernetes_service_label_app]
        action: keep
        regex: node-exporter
Apply the updated Prometheus configuration.

Restart the Prometheus deployment to load the new configuration.

Task 4 - Verify Metrics in Prometheus
Access the Prometheus UI (e.g., by port-forwarding):


Copy
kubectl port-forward svc/prometheus 9090:9090 -n monitoring
In the Prometheus UI, run a query to view Node Exporter metrics:

Example: node_cpu_seconds_total
Ensure metrics are being collected for all cluster nodes.

Task 5 - Explore Metrics Provided by Node Exporter
List and understand key metrics:
node_memory_MemAvailable_bytes: Available memory on the node.
node_filesystem_avail_bytes: Free space on filesystems.
node_network_receive_bytes_total: Total network bytes received.
Use Prometheus expressions to analyze data, e.g.,:
rate(node_network_receive_bytes_total[5m])
Optionally, set up alerts for critical metrics in Prometheus.
Conclusion
By completing this project, you’ve set up Prometheus Node Exporter on Kubernetes, enabling comprehensive monitoring of node-level metrics. You’ve also integrated Node Exporter with Prometheus, learned to query metrics, and explored the data it provides. This setup can now be extended with dashboards (e.g., Grafana) or alerts for advanced monitoring needs.


Previous step
Monitor Linux Server using Prometheus Node Exporter

Next step
Monitoring with 
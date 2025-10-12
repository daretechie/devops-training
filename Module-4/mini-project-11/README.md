# 🚀 Mini Project 11: Setup Prometheus Node Exporter on Kubernetes

## 🎯 Project Overview

**Kubernetes cluster monitoring** is essential for maintaining optimal performance, identifying resource bottlenecks, and ensuring high availability of containerized applications. **Prometheus Node Exporter** combined with **Kubernetes-native deployment** provides comprehensive monitoring of cluster nodes, enabling deep insights into infrastructure health and performance.

In this hands-on project, you'll learn to:
- Deploy Prometheus Node Exporter as a DaemonSet for cluster-wide node monitoring
- Configure Prometheus to automatically discover and scrape Node Exporter metrics
- Set up Kubernetes service discovery for dynamic target management
- Explore comprehensive node-level metrics and their significance
- Implement monitoring best practices for production Kubernetes environments
- Scale monitoring across multiple nodes and namespaces

This project builds on your DevOps and monitoring foundation, demonstrating practical Kubernetes observability that can be extended for enterprise-grade cluster monitoring.

![Kubernetes Node Exporter Monitoring Architecture](./img/kubernetes-monitoring-architecture.png)

---

## 📋 Prerequisites

### Technical Requirements
- **Kubernetes Cluster**: A working Kubernetes cluster (Minikube, Kind, K3s, or managed services like EKS, AKS, GKE)
- **kubectl CLI**: kubectl installed and configured with cluster access
- **Cluster Admin Access**: Ability to create namespaces, deployments, and services
- **Prometheus in Kubernetes**: Prometheus server deployed in the cluster (we'll set this up)
- **Storage**: Sufficient storage for Prometheus metrics (PersistentVolume recommended for production)

### Required Knowledge
- Basic Kubernetes concepts (pods, deployments, services, namespaces)
- Understanding of containerization and Docker concepts
- YAML configuration file management
- Previous completion of monitoring projects (Mini Project 10)

### Project Deliverables for Submission
1. **Screenshots** of each major step and monitoring dashboards
2. **YAML configuration files** (DaemonSet, Service, Prometheus config)
3. **Command outputs** showing successful deployment and verification
4. **Monitoring verification** evidence (metrics queries, service discovery)
5. **Troubleshooting evidence** (if issues occurred)

---

## 🛠️ Step-by-Step Implementation Guide

### Phase 1: Environment Preparation

#### Step 1: Verify Prerequisites

**Objective**: Ensure your Kubernetes environment is ready for monitoring setup.

**Check Kubernetes cluster status:**

```bash
# Verify cluster connectivity
kubectl cluster-info

# Check cluster nodes
kubectl get nodes

# Verify kubectl permissions
kubectl auth can-i create deployments --as=system:serviceaccount:default:default
```

*Expected Output*:
```
Kubernetes control plane is running at https://127.0.0.1:32768
CoreDNS is running at https://127.0.0.1:32768/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

NAME                 STATUS   ROLES           AGE   VERSION
minikube             Ready    control-plane   5h    v1.25.0

Yes, you can create deployments
```

**Check available namespaces:**

```bash
kubectl get namespaces
```

**Verify storage class (for Prometheus persistence):**

```bash
kubectl get storageclass
```

![Prerequisites Verification](./img/k8s-prereq-verification.png)

---

### Phase 2: Prometheus Server Deployment

#### Step 2: Create Monitoring Namespace

**Objective**: Set up a dedicated namespace for monitoring components.

```bash
kubectl create namespace monitoring
```

**Verify namespace creation:**

```bash
kubectl get namespace monitoring
```

*Expected Output*:
```
NAME                 STATUS   AGE
monitoring           Active   10s
```

#### Step 3: Deploy Prometheus Server

**Objective**: Set up Prometheus server in Kubernetes with proper configuration for Node Exporter integration.

**Create Prometheus deployment YAML:**

```bash
cat > prometheus-deployment.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s

    rule_files:
      - "alert_rules.yml"

    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090']

      - job_name: 'node-exporter'
        kubernetes_sd_configs:
          - role: endpoints
            namespaces:
              names:
                - monitoring
        relabel_configs:
          - source_labels: [__meta_kubernetes_service_label_app]
            action: keep
            regex: node-exporter
          - source_labels: [__meta_kubernetes_endpoint_port_name]
            action: keep
            regex: metrics
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
        - name: prometheus
          image: prom/prometheus:latest
          ports:
            - containerPort: 9090
              name: web
          volumeMounts:
            - name: config-volume
              mountPath: /etc/prometheus
            - name: prometheus-storage
              mountPath: /prometheus
          args:
            - '--config.file=/etc/prometheus/prometheus.yml'
            - '--storage.tsdb.path=/prometheus'
            - '--storage.tsdb.retention.time=200h'
            - '--web.console.libraries=/usr/share/prometheus/console_libraries'
            - '--web.console.templates=/usr/share/prometheus/consoles'
            - '--web.enable-lifecycle'
          resources:
            limits:
              memory: "2Gi"
              cpu: "500m"
            requests:
              memory: "1Gi"
              cpu: "250m"
      volumes:
        - name: config-volume
          configMap:
            name: prometheus-config
        - name: prometheus-storage
          persistentVolumeClaim:
            claimName: prometheus-pvc
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: prometheus-pvc
  namespace: monitoring
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: monitoring
spec:
  selector:
    app: prometheus
  ports:
    - port: 9090
      targetPort: 9090
      name: web
  type: ClusterIP
EOF
```

**Deploy Prometheus:**

```bash
kubectl apply -f prometheus-deployment.yaml
```

**Verify Prometheus deployment:**

```bash
# Check deployment status
kubectl get pods -n monitoring

# Check services
kubectl get services -n monitoring

# Check PVC
kubectl get pvc -n monitoring
```

*Expected Output*:
```
NAME                         READY   STATUS    RESTARTS   AGE
prometheus-7d8b9f4c5-abc12   1/1     Running   0          2m

NAME        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
prometheus  ClusterIP   10.96.123.456   <none>        9090/TCP   2m

NAME                STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
prometheus-pvc       Bound    pvc-abc12-def34                            10Gi       RWO            standard       2m
```

![Prometheus Deployment](./img/prometheus-k8s-deployment.png)

---

### Phase 3: Node Exporter DaemonSet Deployment

#### Step 4: Create Node Exporter DaemonSet

**Objective**: Deploy Node Exporter as a DaemonSet to monitor all cluster nodes.

**Create comprehensive Node Exporter DaemonSet YAML:**

```bash
cat > node-exporter-daemonset.yaml << 'EOF'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: node-exporter
  namespace: monitoring
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: node-exporter
rules:
- apiGroups: [""]
  resources: ["nodes", "nodes/proxy", "nodes/metrics", "services", "endpoints", "pods", "ingresses"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: node-exporter
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: node-exporter
subjects:
- kind: ServiceAccount
  name: node-exporter
  namespace: monitoring
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
  labels:
    app: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9100"
        prometheus.io/path: "/metrics"
    spec:
      serviceAccountName: node-exporter
      securityContext:
        runAsNonRoot: true
        runAsUser: 65534
        fsGroup: 65534
      containers:
        - name: node-exporter
          image: prom/node-exporter:v1.6.1
          ports:
            - containerPort: 9100
              protocol: TCP
              name: metrics
              hostPort: 9100
          env:
            - name: HOST_PROC_MOUNT
              value: "/proc"
            - name: HOST_SYS_MOUNT
              value: "/sys"
            - name: HOST_ROOTFS_MOUNT
              value: "/"
          volumeMounts:
            - name: proc
              mountPath: /host/proc
              readOnly: true
            - name: sys
              mountPath: /host/sys
              readOnly: true
            - name: rootfs
              mountPath: /rootfs
              readOnly: true
          securityContext:
            runAsNonRoot: true
            runAsUser: 65534
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop: ["ALL"]
          resources:
            limits:
              memory: "200Mi"
              cpu: "200m"
            requests:
              memory: "100Mi"
              cpu: "100m"
          args:
            - '--web.listen-address=0.0.0.0:9100'
            - '--path.procfs=/host/proc'
            - '--path.sysfs=/host/sys'
            - '--path.rootfs=/rootfs'
            - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
            - '--collector.textfile.directory=/var/lib/node-exporter/textfile'
            - '--web.disable-exporter-metrics'
            - '--no-collector.arp'
            - '--no-collector.bcache'
            - '--no-collector.bonding'
            - '--no-collector.conntrack'
            - '--no-collector.edac'
            - '--no-collector.entropy'
            - '--no-collector.filefd'
            - '--no-collector.hwmon'
            - '--no-collector.infiniband'
            - '--no-collector.ipvs'
            - '--no-collector.mdadm'
            - '--no-collector.netclass'
            - '--no-collector.netstat'
            - '--no-collector.nfs'
            - '--no-collector.nfsd'
            - '--no-collector.pressure'
            - '--no-collector.sockstat'
            - '--no-collector.timex'
            - '--no-collector.udp_queues'
            - '--no-collector.wifi'
            - '--collector.cpu'
            - '--collector.diskstats'
            - '--collector.filesystem'
            - '--collector.loadavg'
            - '--collector.meminfo'
            - '--collector.netdev'
            - '--collector.stat'
            - '--collector.systemd'
            - '--collector.processes'
      volumes:
        - name: proc
          hostPath:
            path: /proc
        - name: sys
          hostPath:
            path: /sys
        - name: rootfs
          hostPath:
            path: /
---
apiVersion: v1
kind: Service
metadata:
  name: node-exporter
  namespace: monitoring
  labels:
    app: node-exporter
spec:
  selector:
    app: node-exporter
  ports:
    - name: metrics
      port: 9100
      targetPort: 9100
      protocol: TCP
  type: ClusterIP
EOF
```

**Deploy Node Exporter DaemonSet:**

```bash
kubectl apply -f node-exporter-daemonset.yaml
```

**Verify Node Exporter deployment:**

```bash
# Check DaemonSet status
kubectl get daemonset -n monitoring

# Check pods (should have one pod per node)
kubectl get pods -n monitoring -l app=node-exporter

# Check service
kubectl get service -n monitoring

# Check service account and RBAC
kubectl get clusterrole,clusterrolebinding -l app=node-exporter
```

*Expected Output*:
```
NAME            DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
node-exporter   1         1         1       1            1           <none>          2m

NAME                            READY   STATUS    RESTARTS   AGE
node-exporter-abc12             1/1     Running   0          1m

NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
node-exporter   ClusterIP   10.96.789.123   <none>        9100/TCP   2m

NAME                              AGE
clusterrole.rbac.authorization.k8s.io/node-exporter      2m
clusterrolebinding.rbac.authorization.k8s.io/node-exporter   2m
```

![Node Exporter DaemonSet](./img/node-exporter-daemonset.png)

---

### Phase 4: Service Discovery and Configuration

#### Step 5: Verify Kubernetes Service Discovery

**Objective**: Confirm that Prometheus can automatically discover Node Exporter endpoints.

**Check Prometheus targets:**

```bash
# Port-forward to access Prometheus UI
kubectl port-forward svc/prometheus 9090:9090 -n monitoring

# In another terminal, check targets via API
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | select(.discoveredLabels.job == "node-exporter") | {instance, health, scrapeUrl}'
```

**Access Prometheus UI:**

1. Open web browser and navigate to `http://localhost:9090`
2. Go to **Status → Targets** to verify Node Exporter endpoints are discovered
3. Check that all nodes show as "UP" with green status

![Prometheus Targets Discovery](./img/prometheus-targets-discovery.png)

#### Step 6: Update Prometheus Configuration for Enhanced Discovery

**Objective**: Optimize Prometheus configuration for better Node Exporter integration.

**Create enhanced Prometheus configuration:**

```bash
cat > prometheus-enhanced-config.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 30s
      evaluation_interval: 30s

    rule_files:
      - "alert_rules.yml"

    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090']

      - job_name: 'node-exporter'
        kubernetes_sd_configs:
          - role: pod
            namespaces:
              names:
                - monitoring
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_label_app]
            action: keep
            regex: node-exporter
          - source_labels: [__meta_kubernetes_pod_container_port_number]
            action: keep
            regex: 9100
          - source_labels: [__meta_kubernetes_pod_node_name]
            target_label: nodename
          - action: replace
            source_labels: [__meta_kubernetes_namespace]
            target_label: namespace
          - action: replace
            source_labels: [__meta_kubernetes_pod_name]
            target_label: pod

      - job_name: 'kubernetes-nodes'
        kubernetes_sd_configs:
          - role: node
        relabel_configs:
          - action: replace
            source_labels: [__meta_kubernetes_node_name]
            target_label: nodename
          - action: replace
            source_labels: [__meta_kubernetes_node_label_kubernetes_io_hostname]
            target_label: instance

      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
            action: keep
            regex: true
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
            action: replace
            target_label: __metrics_path__
            regex: (.+)
          - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
            action: replace
            regex: ([^:]+)(?::\d+)?;(\d+)
            replacement: $1:$2
            target_label: __address__
          - action: replace
            source_labels: [__meta_kubernetes_namespace]
            target_label: namespace
          - action: replace
            source_labels: [__meta_kubernetes_pod_name]
            target_label: pod
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-alert-rules
  namespace: monitoring
data:
  alert_rules.yml: |
    groups:
      - name: node_alerts
        rules:
        - alert: NodeExporterDown
          expr: up{job="node-exporter"} == 0
          for: 5m
          labels:
            severity: critical
          annotations:
            summary: "Node Exporter is down on {{ $labels.nodename }}"
            description: "Node Exporter has been down for more than 5 minutes on node {{ $labels.nodename }}"

        - alert: HighNodeCPUUsage
          expr: (1 - avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m]))) * 100 > 80
          for: 10m
          labels:
            severity: warning
          annotations:
            summary: "High CPU usage on {{ $labels.nodename }}"
            description: "CPU usage is {{ $value }}% on node {{ $labels.nodename }}"

        - alert: HighNodeMemoryUsage
          expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 90
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "High memory usage on {{ $labels.nodename }}"
            description: "Memory usage is {{ $value }}% on node {{ $labels.nodename }}"

        - alert: LowNodeDiskSpace
          expr: (node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100 < 10
          for: 5m
          labels:
            severity: critical
          annotations:
            summary: "Low disk space on {{ $labels.nodename }}"
            description: "Disk usage is {{ $value }}% on {{ $labels.mountpoint }} on node {{ $labels.nodename }}"
EOF
```

**Apply enhanced configuration:**

```bash
kubectl apply -f prometheus-enhanced-config.yaml
kubectl rollout restart deployment/prometheus -n monitoring
```

![Prometheus Enhanced Configuration](./img/prometheus-enhanced-config.png)

---

### Phase 5: Metrics Exploration and Verification

#### Step 7: Explore Node Exporter Metrics

**Objective**: Query and analyze key node metrics using Prometheus Query Language (PromQL).

**Basic metric queries to try:**

```promql
# Node information
node_uname_info

# CPU metrics
node_cpu_seconds_total
rate(node_cpu_seconds_total[5m])

# Memory metrics
node_memory_MemTotal_bytes
node_memory_MemAvailable_bytes
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100

# Filesystem metrics
node_filesystem_size_bytes
node_filesystem_avail_bytes
(node_filesystem_size_bytes - node_filesystem_avail_bytes) / node_filesystem_size_bytes * 100

# Network metrics
node_network_receive_bytes_total
node_network_transmit_bytes_total
rate(node_network_receive_bytes_total[5m])

# Load average
node_load1
node_load5
node_load15

# Disk I/O
node_disk_io_time_seconds_total
rate(node_disk_io_time_seconds_total[5m])

# Process information
node_processes_running
node_processes_blocked
```

**Advanced queries for cluster insights:**

```promql
# Cluster CPU usage across all nodes
sum(rate(node_cpu_seconds_total{mode!="idle"}[5m])) by (nodename) * 100

# Memory usage per node
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) by (nodename)

# Disk usage across cluster
sum(node_filesystem_size_bytes) by (nodename) - sum(node_filesystem_avail_bytes) by (nodename)

# Network I/O per node
rate(node_network_receive_bytes_total[5m]) + rate(node_network_transmit_bytes_total[5m])
```

**Create custom monitoring dashboards:**

1. Go to **Graph** tab in Prometheus UI
2. Enter queries and visualize metrics over time
3. Use **Console** templates for advanced queries

![Metrics Exploration](./img/k8s-metrics-exploration.png)

#### Step 8: Verify Multi-Node Monitoring

**Objective**: Confirm that Node Exporter is collecting metrics from all cluster nodes.

**Check Node Exporter pods across all nodes:**

```bash
kubectl get pods -n monitoring -l app=node-exporter -o wide
```

**Verify metrics collection per node:**

```bash
# Query metrics grouped by node
curl -s "http://localhost:9090/api/v1/query?query=node_uname_info" | jq '.data.result[] | {nodename: .metric.nodename, nodename: .metric.nodename}'

# Check active targets per node
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | select(.labels.job == "node-exporter") | {instance: .labels.instance, nodename: .labels.nodename}'
```

![Multi-Node Verification](./img/multi-node-verification.png)

---

## 🛠️ Troubleshooting Guide

### Common Issues and Solutions

| Problem | Symptoms | Solution |
|---------|----------|----------|
| **DaemonSet Pods Not Starting** | Pods stuck in Pending or Failed state | Check node resources: `kubectl describe node <node-name>`, verify RBAC permissions, check service account |
| **Prometheus Target Down** | Node Exporter shows as DOWN in Prometheus | Verify network policies, check firewall rules, ensure Node Exporter service is accessible |
| **No Metrics in Prometheus** | Queries return "No data" | Check service discovery configuration, verify endpoint annotations, ensure proper relabeling |
| **RBAC Permission Errors** | Access denied errors in logs | Verify ClusterRole and ClusterRoleBinding, check service account permissions |
| **High Resource Usage** | Node Exporter consuming excessive resources | Adjust resource limits/requests in DaemonSet, disable unnecessary collectors |
| **Service Discovery Issues** | Prometheus not discovering Node Exporter endpoints | Check namespace configuration, verify labels and annotations |

### Debugging Commands

```bash
# Check DaemonSet pod logs
kubectl logs -n monitoring -l app=node-exporter

# Describe DaemonSet for detailed status
kubectl describe daemonset node-exporter -n monitoring

# Check Node Exporter metrics endpoint directly
kubectl exec -n monitoring node-exporter-abc12 -- curl http://localhost:9100/metrics | head -20

# Verify Prometheus configuration
kubectl exec -n monitoring prometheus-abc12 -- cat /etc/prometheus/prometheus.yml

# Check Prometheus service discovery
kubectl exec -n monitoring prometheus-abc12 -- curl http://localhost:9090/api/v1/servicediscoveries

# Monitor node resources
kubectl top nodes

# Check pod resources
kubectl top pods -n monitoring

# Verify network connectivity between pods
kubectl exec -n monitoring prometheus-abc12 -- curl http://node-exporter.monitoring:9100/metrics | head -5
```

### Common Error Messages

**`Failed to pull image "prom/node-exporter:latest"`**
- **Cause**: Image pull issues or registry access problems
- **Solution**: Check image registry access, verify network policies, use specific image tag

**`Error: nodes "minikube" not found`**
- **Cause**: Node name mismatch in queries
- **Solution**: Use correct node names from `kubectl get nodes`, check label selectors

**`No data` in Prometheus queries**
- **Cause**: Metrics not being collected or service discovery issues
- **Solution**: Verify target discovery, check relabeling configuration, ensure Node Exporter is running

---

## 📸 Evidence and Screenshots for Submission

### Required Screenshots

1. **Prerequisites Verification**
   - `evidence-01-cluster-info.png` - Kubernetes cluster information
   - `evidence-02-nodes-status.png` - Cluster nodes status
   - `evidence-03-namespaces.png` - Available namespaces

2. **Prometheus Deployment**
   - `evidence-04-prometheus-deployment.png` - Prometheus deployment YAML and status
   - `evidence-05-prometheus-service.png` - Prometheus service configuration
   - `evidence-06-prometheus-pvc.png` - Persistent volume claim status

3. **Node Exporter Deployment**
   - `evidence-07-daemonset-yaml.png` - Node Exporter DaemonSet configuration
   - `evidence-08-daemonset-status.png` - DaemonSet pods across all nodes
   - `evidence-09-node-exporter-service.png` - Node Exporter service configuration
   - `evidence-10-rbac-config.png` - RBAC configuration (ServiceAccount, ClusterRole, ClusterRoleBinding)

4. **Service Discovery and Integration**
   - `evidence-11-targets-page.png` - Prometheus targets page showing Node Exporter endpoints
   - `evidence-12-service-discovery.png` - Service discovery configuration verification
   - `evidence-13-prometheus-ui.png` - Prometheus web interface main page

5. **Metrics Exploration**
   - `evidence-14-node-info-query.png` - Node information query results
   - `evidence-15-cpu-metrics.png` - CPU usage metrics and graphs
   - `evidence-16-memory-metrics.png` - Memory usage metrics and graphs
   - `evidence-17-disk-metrics.png` - Disk space metrics and graphs
   - `evidence-18-network-metrics.png` - Network traffic metrics and graphs

6. **Advanced Features**
   - `evidence-19-alert-rules.png` - Alert rules configuration and status
   - `evidence-20-multi-node-metrics.png` - Metrics from multiple cluster nodes
   - `evidence-21-custom-queries.png` - Advanced PromQL queries and visualizations

### Screenshot Naming Convention
All screenshots should be saved in the `img/` directory with descriptive names:
- `evidence-XX-description.png`
- Include terminal prompts, kubectl commands, and outputs
- Ensure Kubernetes dashboard, Prometheus UI, and YAML files are clearly visible
- Capture both successful deployments and troubleshooting steps

---

## 🎓 Key Concepts Learned

### Kubernetes Monitoring Fundamentals
- **DaemonSet Pattern**: Running pods on every node for cluster-wide monitoring
- **Service Discovery**: Automatic endpoint discovery using Kubernetes API
- **RBAC Security**: Proper role-based access control for monitoring components
- **Resource Management**: Efficient resource allocation for monitoring workloads
- **Multi-tenancy**: Namespace isolation for monitoring components

### Prometheus in Kubernetes
- **Kubernetes SD**: Native service discovery for dynamic environments
- **Relabeling**: Advanced metric labeling and filtering capabilities
- **High Availability**: Scalable monitoring across multiple nodes
- **Persistent Storage**: Data retention and backup strategies
- **Alerting Integration**: Proactive monitoring with rule-based alerts

### Node Exporter Deep Dive
- **Host Metrics**: Comprehensive system and hardware monitoring
- **Container Integration**: Seamless operation in containerized environments
- **Security Context**: Secure deployment with minimal privileges
- **Collector Management**: Selective metric collection for performance
- **Multi-platform Support**: Consistent monitoring across different node types

---

## 🔧 Advanced Configuration Options

### Custom Collectors Configuration
```yaml
args:
  - '--collector.systemd'
  - '--collector.processes'
  - '--collector.cpu.info'
  - '--collector.meminfo.numa'
  - '--collector.diskstats.ignored-devices=^(ram|loop|fd)\d+$'
  - '--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($$|/)'
```

### Network Policies for Security
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: node-exporter-netpol
  namespace: monitoring
spec:
  podSelector:
    matchLabels:
      app: node-exporter
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: prometheus
    ports:
    - protocol: TCP
      port: 9100
```

### Prometheus Operator Integration
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: node-exporter-monitor
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: node-exporter
  endpoints:
  - port: metrics
    interval: 30s
```

### Horizontal Pod Autoscaling for Prometheus
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: prometheus-hpa
  namespace: monitoring
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: prometheus
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

---

## ✅ Project Checklist

- [ ] **Kubernetes cluster verified** (connectivity, nodes, permissions)
- [ ] **Monitoring namespace created** and configured
- [ ] **Prometheus server deployed** with persistent storage and service
- [ ] **Node Exporter DaemonSet deployed** with RBAC and security context
- [ ] **Service discovery configured** for automatic endpoint detection
- [ ] **Prometheus targets verified** (all nodes showing as UP)
- [ ] **Key metrics explored** (CPU, memory, disk, network, filesystem)
- [ ] **Advanced queries tested** with proper PromQL expressions
- [ ] **Alert rules configured** (optional but recommended)
- [ ] **All screenshots captured** for evidence
- [ ] **Troubleshooting documented** (if applicable)

---

## 🚀 Next Steps

With Kubernetes monitoring mastered, you can now:

1. **Grafana Integration**: Add beautiful dashboards for cluster visualization
2. **Alert Manager Setup**: Configure email/Slack notifications for cluster alerts
3. **Application Monitoring**: Add custom metrics for applications running in Kubernetes
4. **Multi-cluster Monitoring**: Extend monitoring across multiple Kubernetes clusters
5. **Performance Optimization**: Use metrics for cluster capacity planning
6. **Compliance Reporting**: Generate monitoring reports for regulatory requirements

---

## 🏆 Project Outcomes

By completing this project, you have:

✅ **Deployed comprehensive Kubernetes monitoring** using Prometheus and Node Exporter
✅ **Configured automatic service discovery** for dynamic cluster environments
✅ **Implemented security best practices** with RBAC and security contexts
✅ **Explored node-level metrics** and their significance in cluster health
✅ **Created scalable monitoring solutions** for production Kubernetes environments
✅ **Gained practical experience** with enterprise-grade cluster observability
✅ **Documented the entire process** for submission and review

**Congratulations on mastering Kubernetes cluster monitoring!** 🎉

This project demonstrates your ability to implement critical observability practices for containerized environments, making you ready for enterprise Kubernetes administration and DevOps observability roles.

For questions or issues, refer to the troubleshooting section or consult the official Prometheus and Kubernetes documentation.

---

## 📚 Additional Resources

- **Prometheus Operator**: [https://prometheus-operator.dev/](https://prometheus-operator.dev/)
- **Kubernetes Monitoring Guide**: [https://kubernetes.io/docs/tasks/debug/debug-cluster/monitor-node-health/](https://kubernetes.io/docs/tasks/debug/debug-cluster/monitor-node-health/)
- **Node Exporter Documentation**: [https://prometheus.io/docs/guides/node-exporter/](https://prometheus.io/docs/guides/node-exporter/)
- **Prometheus Kubernetes SD**: [https://prometheus.io/docs/prometheus/latest/configuration/configuration/#kubernetes_sd_config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#kubernetes_sd_config)
- **Monitoring Best Practices**: [https://sre.google/sre-book/monitoring-distributed-systems/](https://sre.google/sre-book/monitoring-distributed-systems/)
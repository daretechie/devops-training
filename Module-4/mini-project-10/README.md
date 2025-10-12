# 🚀 Mini Project 10: Monitor Linux Server using Prometheus Node Exporter

## 🎯 Project Overview

**System monitoring** is crucial for maintaining optimal server performance, identifying issues before they become critical, and ensuring high availability of services. **Prometheus Node Exporter** is a powerful, lightweight tool that collects comprehensive hardware and operating system metrics from Linux servers, providing deep insights into system health and performance.

In this hands-on project, you'll learn to:
- Install and configure Prometheus Node Exporter for comprehensive system monitoring
- Set up Prometheus server to collect and store metrics
- Create effective monitoring dashboards and alerting rules
- Understand key system metrics and their significance
- Implement monitoring best practices for production environments
- Scale monitoring across multiple servers and services

This project builds on your DevOps foundation and demonstrates practical system monitoring that can be extended for enterprise-grade observability solutions.

![Prometheus Node Exporter Monitoring Architecture](./img/prometheus-monitoring-architecture.png)

---

## 📋 Prerequisites

### Technical Requirements
- **Monitoring Server**: A Linux server/VM to run Prometheus (Ubuntu/Debian preferred)
- **Target Server(s)**: Linux server(s) to monitor with Node Exporter
- **Network Connectivity**: Both servers must be able to communicate (Prometheus → Node Exporter on port 9100)
- **Storage Space**: Sufficient space for Prometheus data storage (TSDB)
- **Memory**: At least 2GB RAM recommended for Prometheus server

### Required Knowledge
- Basic Linux command line skills and system administration
- Understanding of networking concepts (ports, firewalls)
- Text editor familiarity (nano, vim, etc.)
- Previous completion of Ansible projects (Mini Projects 6-9)

### Project Deliverables for Submission
1. **Screenshots** of each major step and monitoring dashboards
2. **Configuration files** (Prometheus config, systemd services)
3. **Command outputs** showing successful Node Exporter and Prometheus setup
4. **Monitoring verification** evidence (metrics queries, graphs, targets status)
5. **Troubleshooting evidence** (if issues occurred)

---

## 🛠️ Step-by-Step Implementation Guide

### Phase 1: Environment Preparation

#### Step 1: Verify Prerequisites

**Objective**: Ensure your system is ready for monitoring setup.

1. **Check Linux Distribution**:
```bash
cat /etc/os-release
```
*Expected Output*: Should show Ubuntu, Debian, or similar Linux distribution.

2. **Verify Sudo Access**:
```bash
sudo whoami
```
*Expected Output*: Should return `root` (confirming sudo privileges).

3. **Check Network Connectivity**:
```bash
ping -c 3 google.com
```
*Expected Output*: Successful ping responses.

4. **Check Available Resources**:
```bash
# Memory check
free -h

# Disk space check
df -h

# CPU information
nproc
```
*Expected Output*: System resource information for capacity planning.

![Prerequisites Verification](./img/prereq-verification.png)

---

### Phase 2: Prometheus Server Setup

#### Step 2: Install Prometheus Server

**Objective**: Set up Prometheus server to collect and store monitoring metrics.

**Download and install Prometheus:**

```bash
# Create prometheus user and directories
sudo useradd --no-create-home --shell /bin/false prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

# Download Prometheus
curl -LO https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz

# Extract and install
tar -xvf prometheus-2.45.0.linux-amd64.tar.gz
sudo cp prometheus-2.45.0.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-2.45.0.linux-amd64/promtool /usr/local/bin/
sudo cp -r prometheus-2.45.0.linux-amd64/consoles /etc/prometheus
sudo cp -r prometheus-2.45.0.linux-amd64/console_libraries /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus/*
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

# Cleanup
rm -rf prometheus-2.45.0.linux-amd64*
```

**Create Prometheus configuration file:**

```bash
sudo tee /etc/prometheus/prometheus.yml > /dev/null << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
    scrape_interval: 30s
EOF
```

**Create Prometheus systemd service:**

```bash
sudo tee /etc/systemd/system/prometheus.service > /dev/null << 'EOF'
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries \
    --storage.tsdb.retention.time=200h \
    --web.listen-address=0.0.0.0:9090 \
    --web.external-url=

ExecReload=/bin/kill -HUP $MAINPID
Restart=always

[Install]
WantedBy=multi-user.target
EOF
```

**Start Prometheus service:**

```bash
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
sudo systemctl status prometheus
```

**Verify Prometheus is running:**

```bash
# Check service status
sudo systemctl status prometheus

# Test web interface
curl http://localhost:9090

# Check targets (should show prometheus and node-exporter if installed locally)
curl http://localhost:9090/api/v1/targets
```

![Prometheus Installation](./img/prometheus-installation.png)

---

### Phase 3: Node Exporter Installation

#### Step 3: Install Node Exporter

**Objective**: Install Node Exporter on the server you want to monitor.

```bash
# Download Node Exporter
curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz

# Extract
tar -xvf node_exporter-1.6.1.linux-amd64.tar.gz

# Install binary
sudo mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Cleanup
rm -rf node_exporter-1.6.1.linux-amd64*
```

**Create Node Exporter systemd service:**

```bash
sudo tee /etc/systemd/system/node_exporter.service > /dev/null << 'EOF'
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter \
    --web.listen-address=:9100 \
    --web.telemetry-path=/metrics \
    --collector.systemd \
    --collector.processes \
    --collector.cpu \
    --collector.meminfo \
    --collector.diskstats \
    --collector.filesystem \
    --collector.loadavg \
    --collector.netstat \
    --collector.stat \
    --collector.interrupts \
    --collector.ksmd

ExecReload=/bin/kill -HUP $MAINPID
Restart=always

[Install]
WantedBy=multi-user.target
EOF
```

**Create node_exporter user and start service:**

```bash
sudo useradd --no-create-home --shell /bin/false node_exporter
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
sudo systemctl status node_exporter
```

**Verify Node Exporter is working:**

```bash
# Check service status
sudo systemctl status node_exporter

# Test metrics endpoint
curl http://localhost:9100/metrics | head -20

# Check listening port
sudo netstat -tlnp | grep :9100
```

![Node Exporter Installation](./img/node-exporter-installation.png)

---

### Phase 4: Prometheus Configuration

#### Step 4: Configure Prometheus to Scrape Node Exporter

**Objective**: Update Prometheus configuration to collect metrics from Node Exporter.

**Update the Prometheus configuration file:**

```bash
sudo nano /etc/prometheus/prometheus.yml
```

**Enhanced configuration example:**

```yaml
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
    static_configs:
      - targets: ['TARGET_SERVER_IP:9100']  # Replace with your target server IP
    scrape_interval: 30s
    metrics_path: /metrics
    params:
      format: ['prometheus']

  # Optional: Monitor multiple servers
  - job_name: 'web-servers'
    static_configs:
      - targets: ['web1.example.com:9100', 'web2.example.com:9100']
```

**Create alert rules file:**

```bash
sudo tee /etc/prometheus/alert_rules.yml > /dev/null << 'EOF'
groups:
  - name: server_alerts
    rules:
    - alert: HighCPUUsage
      expr: 100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High CPU usage detected"
        description: "CPU usage is {{ $value }}% on {{ $labels.instance }}"

    - alert: HighMemoryUsage
      expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 90
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High memory usage"
        description: "Memory usage is {{ $value }}% on {{ $labels.instance }}"

    - alert: LowDiskSpace
      expr: (node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100 < 10
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Low disk space"
        description: "Disk usage is {{ $value }}% on {{ $labels.instance }}"
EOF
```

**Restart Prometheus to apply changes:**

```bash
sudo systemctl restart prometheus
sudo systemctl status prometheus
```

![Prometheus Configuration](./img/prometheus-configuration.png)

---

### Phase 5: Monitoring Verification and Exploration

#### Step 5: Verify Node Exporter Integration

**Objective**: Confirm that Prometheus is successfully collecting metrics from Node Exporter.

**Access Prometheus web interface:**

1. Open web browser and navigate to `http://PROMETHEUS_SERVER_IP:9090`
2. Go to **Status → Targets** to verify Node Exporter is listed as "UP"
3. Check that the endpoint shows `http://TARGET_SERVER_IP:9100/metrics`

![Targets Status](./img/targets-status.png)

#### Step 6: Explore System Metrics

**Objective**: Query and analyze key system metrics using Prometheus Query Language (PromQL).

**Basic metric queries to try:**

```promql
# CPU Usage
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory Usage
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100

# Disk Usage
100 - ((node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100)

# Network Traffic
rate(node_network_receive_bytes_total[5m])

# Load Average
node_load1

# File System Information
node_filesystem_size_bytes / node_filesystem_avail_bytes

# Process Count
node_processes_running
```

**Advanced queries with time ranges:**

```promql
# CPU usage over last 5 minutes
rate(node_cpu_seconds_total[5m])

# Memory usage trend over last hour
avg_over_time(node_memory_MemAvailable_bytes[1h])

# Network I/O rate
rate(node_network_receive_bytes_total{device!="lo"}[5m])

# Disk I/O operations
rate(node_disk_io_time_seconds_total[5m])
```

**Create custom dashboards:**

1. Go to **Graph** tab in Prometheus UI
2. Enter queries and visualize metrics over time
3. Use **Console** templates for advanced queries

![Metrics Exploration](./img/metrics-exploration.png)

#### Step 7: Set Up Basic Alerting (Optional)

**Objective**: Configure alerting rules for critical system conditions.

**Test alert rules:**

```bash
# Check if alert rules are loaded
curl http://localhost:9090/api/v1/rules

# View current alerts
curl http://localhost:9090/api/v1/alerts

# Simulate high CPU usage to test alerts
stress -c 4  # This will generate CPU load
```

**Monitor alert status in Prometheus UI:**

1. Go to **Alerts** tab to view active alerts
2. Check **Status → Rules** to see configured alert rules

![Alert Configuration](./img/alert-configuration.png)

---

## 🛠️ Troubleshooting Guide

### Common Issues and Solutions

| Problem | Symptoms | Solution |
|---------|----------|----------|
| **Node Exporter Not Accessible** | `curl http://localhost:9100/metrics` returns connection refused | Check service status: `sudo systemctl status node_exporter`, verify port 9100 is open in firewall |
| **Prometheus Target Down** | Target shows as "DOWN" in Prometheus UI | Verify network connectivity, check firewall rules, ensure Node Exporter is running |
| **No Metrics in Prometheus** | Queries return "No data" | Check Prometheus configuration, verify scrape targets, ensure Node Exporter is exporting metrics |
| **High Memory Usage** | Prometheus consuming too much memory | Adjust retention time in config, increase memory allocation, use remote storage |
| **Service Startup Failures** | Systemd service fails to start | Check logs: `sudo journalctl -u prometheus -f`, verify file permissions and paths |
| **Configuration Errors** | Prometheus fails to reload config | Test config: `promtool check config /etc/prometheus/prometheus.yml`, check YAML syntax |

### Debugging Commands

```bash
# Check Node Exporter service logs
sudo journalctl -u node_exporter -f

# Check Prometheus service logs
sudo journalctl -u prometheus -f

# Test Node Exporter metrics endpoint
curl -s http://localhost:9100/metrics | grep -E "(node_cpu|node_memory)" | head -10

# Check Prometheus targets via API
curl -s http://localhost:9090/api/v1/targets

# Verify Prometheus configuration
curl -s http://localhost:9090/api/v1/status/config

# Check active alerts
curl -s http://localhost:9090/api/v1/alerts

# Monitor system resources
htop  # Or top, free -h, df -h

# Check network connectivity
telnet TARGET_IP 9100
```

### Common Error Messages

**`listen tcp :9100: bind: address already in use`**
- **Cause**: Another service is using port 9100
- **Solution**: Change Node Exporter port or stop conflicting service

**`Target down`**
- **Cause**: Network connectivity issues or firewall blocking
- **Solution**: Check firewall: `sudo ufw allow 9100`, verify target server accessibility

**`No data` in queries**
- **Cause**: Metrics not being collected or configuration issues
- **Solution**: Verify Prometheus config, check target status, ensure Node Exporter is running

---

## 📸 Evidence and Screenshots for Submission

### Required Screenshots

1. **Prerequisites Verification**
   - `evidence-01-system-info.png` - OS, resources, and network verification
   - `evidence-02-prometheus-version.png` - Prometheus installation verification

2. **Installation and Configuration**
   - `evidence-03-node-exporter-download.png` - Node Exporter download and installation
   - `evidence-04-node-exporter-service.png` - Node Exporter service status
   - `evidence-05-prometheus-service.png` - Prometheus service status
   - `evidence-06-prometheus-config.png` - Prometheus configuration file

3. **Integration Verification**
   - `evidence-07-targets-status.png` - Prometheus targets page showing Node Exporter as UP
   - `evidence-08-metrics-endpoint.png` - Node Exporter /metrics endpoint output
   - `evidence-09-prometheus-ui.png` - Prometheus web interface main page

4. **Metrics Exploration**
   - `evidence-10-cpu-query.png` - CPU usage query in Prometheus
   - `evidence-11-memory-query.png` - Memory usage query in Prometheus
   - `evidence-12-disk-query.png` - Disk space query in Prometheus
   - `evidence-13-network-query.png` - Network traffic query in Prometheus
   - `evidence-14-custom-graph.png` - Custom time-series graph

5. **Advanced Features**
   - `evidence-15-alert-rules.png` - Alert rules configuration (if implemented)
   - `evidence-16-alert-status.png` - Active alerts status (if triggered)
   - `evidence-17-multi-target.png` - Multiple targets configuration (if using multiple servers)

### Screenshot Naming Convention
All screenshots should be saved in the `img/` directory with descriptive names:
- `evidence-XX-description.png`
- Include terminal prompts and outputs
- Ensure text is readable and URLs/commands are visible
- Capture both successful and failed attempts (for troubleshooting evidence)

---

## 🎓 Key Concepts Learned

### System Monitoring Fundamentals
- **Metrics Collection**: Automated gathering of system performance data
- **Time Series Data**: Historical data storage and analysis
- **Alerting**: Proactive notification of system issues
- **Dashboards**: Visual representation of system health
- **Service Discovery**: Automatic detection of monitoring targets

### Prometheus Architecture
- **Pull-based Model**: Prometheus actively scrapes metrics from targets
- **TSDB (Time Series Database)**: Efficient storage of time-series data
- **PromQL**: Powerful query language for metrics analysis
- **Exporters**: Standardized metric collection from various systems
- **Alertmanager**: Handles alerting and notification routing

### Monitoring Best Practices
- **Golden Signals**: Latency, Traffic, Errors, Saturation
- **Cardinality**: Managing metric label combinations
- **Retention Policies**: Data lifecycle management
- **High Availability**: Redundant monitoring setup
- **Security**: Secure communication and access controls

---

## 🔧 Advanced Configuration Options

### Multi-Server Monitoring
```yaml
scrape_configs:
  - job_name: 'node-servers'
    static_configs:
      - targets: ['server1:9100', 'server2:9100', 'server3:9100']
    labels:
      environment: 'production'

  - job_name: 'web-servers'
    static_configs:
      - targets: ['web1:9100', 'web2:9100']
    labels:
      service: 'web'
```

### Service Discovery with Consul
```yaml
scrape_configs:
  - job_name: 'node-exporter'
    consul_sd_configs:
      - server: 'consul-server:8500'
        services: ['node-exporter']
```

### Remote Storage Configuration
```yaml
remote_write:
  - url: "https://remote-storage.example.com/write"
    queue_config:
      max_samples_per_send: 1000

remote_read:
  - url: "https://remote-storage.example.com/read"
```

### Recording Rules for Performance
```yaml
groups:
  - name: cpu_recording_rules
    rules:
    - record: cpu_usage_percent
      expr: 100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

---

## ✅ Project Checklist

- [ ] **Prerequisites verified** (OS, resources, network connectivity)
- [ ] **Prometheus server installed** and running on port 9090
- [ ] **Node Exporter installed** and running on port 9100
- [ ] **Prometheus configured** to scrape Node Exporter metrics
- [ ] **Integration verified** (targets showing as UP in Prometheus UI)
- [ ] **Key metrics queried** (CPU, memory, disk, network)
- [ ] **Custom graphs created** using PromQL expressions
- [ ] **Prometheus web interface** explored and documented
- [ ] **All screenshots captured** for evidence
- [ ] **Troubleshooting documented** (if applicable)

---

## 🚀 Next Steps

With system monitoring mastered, you can now:

1. **Grafana Integration**: Add beautiful dashboards for visualization
2. **Alert Manager Setup**: Configure email/Slack notifications for alerts
3. **Application Monitoring**: Add custom application metrics
4. **Distributed Monitoring**: Scale across multiple data centers
5. **Performance Optimization**: Use metrics for capacity planning
6. **Compliance Reporting**: Generate monitoring reports for audits

---

## 🏆 Project Outcomes

By completing this project, you have:

✅ **Deployed comprehensive system monitoring** using Prometheus and Node Exporter
✅ **Configured automated metric collection** from Linux servers
✅ **Implemented alerting rules** for critical system conditions
✅ **Explored key system metrics** and their significance
✅ **Created monitoring dashboards** for operational visibility
✅ **Gained practical experience** with production-grade monitoring tools
✅ **Documented the entire process** for submission and review

**Congratulations on mastering Linux server monitoring with Prometheus!** 🎉

This project demonstrates your ability to implement critical observability practices, making you ready for enterprise monitoring administration and DevOps observability roles.

For questions or issues, refer to the troubleshooting section or consult the official Prometheus documentation.

---

## 📚 Additional Resources

- **Prometheus Official Documentation**: [https://prometheus.io/docs/](https://prometheus.io/docs/)
- **Node Exporter Documentation**: [https://prometheus.io/docs/guides/node-exporter/](https://prometheus.io/docs/guides/node-exporter/)
- **PromQL Tutorial**: [https://prometheus.io/docs/prometheus/latest/querying/basics/](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- **Grafana Integration**: [https://grafana.com/docs/grafana/latest/datasources/prometheus/](https://grafana.com/docs/grafana/latest/datasources/prometheus/)
- **Monitoring Best Practices**: [https://sre.google/sre-book/monitoring-distributed-systems/](https://sre.google/sre-book/monitoring-distributed-systems/)
# 🚀 Mini Project 12: Configuring Uptime Monitoring using Gatus

## 🎯 Project Overview

**Uptime monitoring** is critical for ensuring service availability, maintaining user satisfaction, and meeting business continuity requirements. **Gatus** is a lightweight yet powerful monitoring tool that provides real-time health checks for websites, APIs, and services, with beautiful dashboards and flexible alerting capabilities.

In this hands-on project, you'll learn to:
- Install and configure Gatus for comprehensive uptime monitoring
- Set up health checks for multiple endpoints with custom conditions
- Configure alerting for downtime events using multiple notification methods
- Create custom dashboards and monitoring reports
- Implement monitoring best practices for production environments
- Scale monitoring across multiple services and environments

This project builds on your DevOps monitoring foundation and demonstrates practical uptime monitoring that can be extended for enterprise-grade service availability monitoring.

![Gatus Uptime Monitoring Dashboard](./img/gatus-monitoring-dashboard.png)

---

## 📋 Prerequisites

### Technical Requirements
- **Docker Environment**: Docker installed and running (Docker Desktop, Docker Engine, or similar)
- **Network Access**: Internet connectivity for testing external endpoints
- **Storage Space**: Minimal storage requirements for Gatus configuration and logs
- **Memory**: At least 512MB RAM available for Gatus container
- **Web Browser**: Modern browser for accessing Gatus dashboard

### Required Knowledge
- Basic understanding of HTTP status codes and API endpoints
- Familiarity with YAML configuration files
- Basic Docker concepts (containers, volumes, ports)
- Previous completion of monitoring projects (Mini Projects 10-11)

### Project Deliverables for Submission
1. **Screenshots** of each major step and monitoring dashboards
2. **Configuration files** (Gatus config.yaml with multiple endpoints)
3. **Command outputs** showing successful Gatus deployment and configuration
4. **Monitoring verification** evidence (dashboard screenshots, alert testing)
5. **Troubleshooting evidence** (if issues occurred)

---

## 🛠️ Step-by-Step Implementation Guide

### Phase 1: Environment Preparation

#### Step 1: Verify Prerequisites

**Objective**: Ensure your system is ready for Gatus deployment.

**Check Docker installation:**

```bash
# Verify Docker is installed and running
docker --version

# Check Docker daemon status
sudo systemctl status docker  # Linux
# OR
docker info  # macOS/Windows
```

*Expected Output*:
```
Docker version 24.0.6, build ed223bc
Client: Docker Engine - Community
 Version:          24.0.6
...
```

**Check available resources:**

```bash
# Memory check
free -h  # Linux
# OR
docker run --rm -it busybox free -h  # Cross-platform

# Disk space check
df -h

# Network connectivity
ping -c 3 google.com
```

*Expected Output*: Sufficient resources available and network connectivity confirmed.

![Prerequisites Verification](./img/prereq-verification.png)

---

### Phase 2: Gatus Installation and Setup

#### Step 2: Install Docker (if not already installed)

**Objective**: Ensure Docker is available for running Gatus containerized.

**For Ubuntu/Debian:**

```bash
# Update package index
sudo apt update

# Install required packages
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up stable repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group (optional, for non-root usage)
sudo usermod -aG docker $USER
```

**For CentOS/RHEL:**

```bash
# Install Docker
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker
```

**Verify Docker installation:**

```bash
# Check Docker version
docker --version

# Test Docker with hello-world
docker run hello-world

# Check Docker status
sudo systemctl status docker
```

![Docker Installation](./img/docker-installation.png)

#### Step 3: Deploy Gatus Container

**Objective**: Set up Gatus using Docker with proper configuration mounting.

**Create Gatus project directory:**

```bash
# Create dedicated directory for Gatus project
mkdir ~/gatus-monitoring
cd ~/gatus-monitoring

# Create subdirectories for organization
mkdir -p config data logs
```

**Pull Gatus Docker image:**

```bash
# Download the latest Gatus image
docker pull twinproduction/gatus:latest
```

*Expected Output*:
```
latest: Pulling from twinproduction/gatus
Digest: sha256:abc123...
Status: Downloaded newer image for twinproduction/gatus:latest
```

**Create initial Gatus configuration:**

```bash
cat > config/config.yaml << 'EOF'
# Gatus Configuration File
# This file defines endpoints to monitor and alerting configuration

# Global configuration
metrics: true
storage:
  type: "memory"  # Use "sqlite" for persistent storage
  path: "./data/db.sqlite"

# Web UI configuration
web:
  address: "0.0.0.0:8080"
  basic-auth:
    # username: "admin"
    # password: "admin"

# Endpoints to monitor
endpoints:
  - name: "Google"
    url: "https://www.google.com"
    interval: 30s
    conditions:
      - "[STATUS] == 200"
      - "[RESPONSE_TIME] < 3000"  # Response time under 3 seconds
    alerts:
      - type: "slack"
        enabled: false  # Will configure later

  - name: "GitHub"
    url: "https://github.com"
    interval: 60s
    conditions:
      - "[STATUS] == 200"
      - "[RESPONSE_TIME] < 5000"
    alerts:
      - type: "slack"
        enabled: false

# Alerting configuration (will be configured in next steps)
alerting:
  slack:
    webhook-url: "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
    default-alert:
      enabled: false
EOF
```

**Start Gatus container:**

```bash
# Run Gatus container with volume mounts
docker run -d \
  --name gatus \
  -p 8080:8080 \
  -v $(pwd)/config:/config \
  -v $(pwd)/data:/data \
  -v $(pwd)/logs:/logs \
  --restart unless-stopped \
  twinproduction/gatus:latest
```

**Verify Gatus deployment:**

```bash
# Check container status
docker ps | grep gatus

# Check container logs
docker logs gatus

# Test Gatus web interface
curl -I http://localhost:8080

# Check Gatus health endpoint
curl http://localhost:8080/health
```

*Expected Output*:
```
CONTAINER ID   IMAGE                        COMMAND                  CREATED          STATUS          PORTS                    NAMES
abc123def456   twinproduction/gatus:latest   "/gatus"                 2 minutes ago    Up 2 minutes    0.0.0.0:8080->8080/tcp   gatus

HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
Content-Length: 1234

{"status": "healthy"}
```

![Gatus Deployment](./img/gatus-deployment.png)

---

### Phase 3: Endpoint Configuration and Monitoring

#### Step 4: Configure Multiple Endpoints

**Objective**: Set up comprehensive monitoring for various types of services and endpoints.

**Enhanced configuration with multiple endpoint types:**

```bash
cat > config/config.yaml << 'EOF'
# Enhanced Gatus Configuration with Multiple Endpoints

# Global settings
metrics: true
storage:
  type: "sqlite"
  path: "./data/db.sqlite"

web:
  address: "0.0.0.0:8080"

# Monitored endpoints
endpoints:
  # Web Services
  - name: "Google Homepage"
    group: "Web Services"
    url: "https://www.google.com"
    interval: 30s
    conditions:
      - "[STATUS] == 200"
      - "[RESPONSE_TIME] < 3000"
      - "[BODY] != null"
    alerts:
      - type: "slack"
        enabled: false

  - name: "GitHub Homepage"
    group: "Web Services"
    url: "https://github.com"
    interval: 60s
    conditions:
      - "[STATUS] == 200"
      - "[RESPONSE_TIME] < 5000"
    alerts:
      - type: "slack"
        enabled: false

  - name: "HTTPBin API"
    group: "APIs"
    url: "https://httpbin.org/get"
    interval: 30s
    conditions:
      - "[STATUS] == 200"
      - "[RESPONSE_TIME] < 2000"
      - "[CONNECTED] == true"
    alerts:
      - type: "slack"
        enabled: false

  # DNS Resolution
  - name: "Google DNS"
    group: "DNS"
    url: "https://dns.google/resolve?name=example.com"
    interval: 60s
    conditions:
      - "[STATUS] == 200"
      - "[JSON_PATH] $.Status == 0"
    alerts:
      - type: "slack"
        enabled: false

  # SSL Certificate Check
  - name: "Google SSL"
    group: "SSL/TLS"
    url: "https://www.google.com"
    interval: 24h  # Check daily
    conditions:
      - "[CERTIFICATE_EXPIRY] > 7"  # Expires in more than 7 days
    alerts:
      - type: "slack"
        enabled: false

  # ICMP Ping (if supported by environment)
  - name: "Google Ping"
    group: "Network"
    url: "icmp://8.8.8.8"
    interval: 60s
    conditions:
      - "[CONNECTED] == true"
      - "[RESPONSE_TIME] < 100"
    alerts:
      - type: "slack"
        enabled: false

# UI Customization
ui:
  title: "My Uptime Monitoring Dashboard"
  description: "Monitoring critical services and endpoints"
  header: "🚀 Uptime Monitor"
  logo: "https://via.placeholder.com/150x50.png?text=Gatus"
  buttons:
    - name: "GitHub"
      link: "https://github.com/TwiN/gatus"
    - name: "Documentation"
      link: "https://gatus.io/"

# Advanced conditions and alerting
conditions:
  - name: "response_time_critical"
    description: "Response time is critical"
EOF
```

**Restart Gatus to apply configuration:**

```bash
# Stop current container
docker stop gatus

# Start with new configuration
docker start gatus

# Or restart with new config
docker restart gatus
```

**Verify endpoint configuration:**

```bash
# Check Gatus is responding
curl -s http://localhost:8080/api/v1/endpoints | jq '.endpoints[] | {name, group}'

# View configuration in web UI
# Open http://localhost:8080 in browser
```

![Endpoint Configuration](./img/endpoint-configuration.png)

#### Step 5: Test Monitoring with Various Conditions

**Objective**: Verify Gatus monitoring effectiveness with different endpoint types and conditions.

**Test different monitoring scenarios:**

```bash
# Test with a failing endpoint (simulate downtime)
curl -I https://httpstat.us/500  # Server error
curl -I https://httpstat.us/404  # Not found
curl -I https://httpstat.us/200  # Success

# Test slow response
curl -w "@curl-format.txt" -o /dev/null -s https://httpbin.org/delay/2
```

**Create curl-format.txt for response time testing:**

```bash
cat > curl-format.txt << 'EOF'
     time_namelookup:  %{time_namelookup}\n
        time_connect:  %{time_connect}\n
     time_appconnect:  %{time_appconnect}\n
    time_pretransfer:  %{time_pretransfer}\n
       time_redirect:  %{time_redirect}\n
  time_starttransfer:  %{time_starttransfer}\n
                     ----------\n
          time_total:  %{time_total}\n
EOF
```

**Monitor Gatus dashboard:**

1. Open `http://localhost:8080` in web browser
2. Observe endpoint status and response times
3. Check historical data and uptime statistics
4. View detailed metrics for each endpoint

![Gatus Dashboard](./img/gatus-dashboard.png)

---

### Phase 4: Alerting Configuration

#### Step 6: Set Up Slack Alerting

**Objective**: Configure Slack notifications for downtime events.

**Create Slack webhook (if not already exists):**

1. Go to [Slack Apps](https://api.slack.com/apps)
2. Create new app for your workspace
3. Add "Incoming Webhooks" feature
4. Create webhook for your desired channel
5. Copy the webhook URL

**Update Gatus configuration with Slack alerting:**

```bash
cat > config/config.yaml << 'EOF'
# Gatus Configuration with Slack Alerting

# Global settings
metrics: true
storage:
  type: "sqlite"
  path: "./data/db.sqlite"

web:
  address: "0.0.0.0:8080"

# Alerting configuration
alerting:
  slack:
    webhook-url: "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK/URL"
    default-alert:
      enabled: true
      send-on-resolved: true
      failure-threshold: 3
      success-threshold: 2
    custom:
      default-alert:
        title: "🚨 Service Alert"
        description: "Service {{ .Endpoint.Name }} is {{ .Condition }}"

# Monitored endpoints with alerting
endpoints:
  - name: "Google Homepage"
    group: "Web Services"
    url: "https://www.google.com"
    interval: 30s
    conditions:
      - "[STATUS] == 200"
      - "[RESPONSE_TIME] < 3000"
    alerts:
      - type: "slack"
        enabled: true
        failure-threshold: 3
        success-threshold: 2
        send-on-resolved: true

  - name: "GitHub Homepage"
    group: "Web Services"
    url: "https://github.com"
    interval: 60s
    conditions:
      - "[STATUS] == 200"
      - "[RESPONSE_TIME] < 5000"
    alerts:
      - type: "slack"
        enabled: true

  - name: "Simulated Failure Test"
    group: "Testing"
    url: "https://httpstat.us/200"
    interval: 60s
    conditions:
      - "[STATUS] == 500"  # This will fail to test alerts
    alerts:
      - type: "slack"
        enabled: true
        failure-threshold: 1
        send-on-resolved: true
EOF
```

**Apply Slack alerting configuration:**

```bash
# Restart Gatus with new configuration
docker restart gatus

# Check logs for any configuration errors
docker logs gatus | tail -20
```

![Slack Alerting Configuration](./img/slack-alerting.png)

#### Step 7: Test Alert Functionality

**Objective**: Verify that alerts are properly configured and functioning.

**Test alert triggers:**

```bash
# Create a test endpoint that will fail
cat >> config/config.yaml << 'EOF'

  - name: "Test Failure Endpoint"
    group: "Testing"
    url: "https://httpstat.us/500"
    interval: 30s
    conditions:
      - "[STATUS] == 200"  # This will always fail
    alerts:
      - type: "slack"
        enabled: true
        failure-threshold: 1
        send-on-resolved: true
EOF

# Restart Gatus
docker restart gatus

# Monitor for alerts in Slack
# Check Gatus logs
docker logs -f gatus
```

**Verify alert delivery:**

1. Check Slack channel for alert notifications
2. Monitor Gatus dashboard for alert status
3. Verify alert resolution when endpoint recovers
4. Check alert history in Gatus logs

![Alert Testing](./img/alert-testing.png)

---

### Phase 5: Advanced Configuration and Customization

#### Step 8: Configure Email Alerting (Alternative)

**Objective**: Set up email notifications as an alternative to Slack.

**Install and configure email alerting:**

```bash
# For SMTP email alerts, add to config.yaml
cat >> config/config.yaml << 'EOF'

# Email alerting configuration
alerting:
  email:
    from: "gatus@example.com"
    username: "your-email@gmail.com"
    password: "your-app-password"
    host: "smtp.gmail.com"
    port: 587
    to:
      - "admin@example.com"
EOF
```

**Set up endpoints with email alerts:**

```yaml
endpoints:
  - name: "Critical API"
    url: "https://api.example.com/health"
    interval: 60s
    conditions:
      - "[STATUS] == 200"
    alerts:
      - type: "email"
        enabled: true
        failure-threshold: 2
        success-threshold: 1
```

#### Step 9: Dashboard Customization

**Objective**: Customize Gatus dashboard for better monitoring experience.

**Enhanced UI configuration:**

```bash
cat > config/config.yaml << 'EOF'
# Complete Gatus Configuration

# Global settings
metrics: true
storage:
  type: "sqlite"
  path: "./data/db.sqlite"

web:
  address: "0.0.0.0:8080"

# UI Customization
ui:
  title: "Enterprise Uptime Monitor"
  description: "Comprehensive service availability monitoring"
  header: "🔍 Service Monitor"
  logo: "https://via.placeholder.com/200x60.png?text=UPTIME"
  buttons:
    - name: "Gatus Docs"
      link: "https://gatus.io/"
    - name: "GitHub"
      link: "https://github.com/TwiN/gatus"
    - name: "Status Page"
      link: "https://status.example.com"

# Alerting configuration
alerting:
  slack:
    webhook-url: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
    default-alert:
      enabled: true
      send-on-resolved: true
      failure-threshold: 3
      success-threshold: 2

# Monitored endpoints
endpoints:
  # Production Services
  - name: "Main Website"
    group: "Production"
    url: "https://example.com"
    interval: 30s
    conditions:
      - "[STATUS] == 200"
      - "[RESPONSE_TIME] < 2000"
      - "[CONNECTED] == true"
    alerts:
      - type: "slack"
        enabled: true

  # Development Services
  - name: "Dev API"
    group: "Development"
    url: "https://dev-api.example.com/health"
    interval: 60s
    conditions:
      - "[STATUS] == 200"
      - "[JSON_PATH] $.status == \"healthy\""
    alerts:
      - type: "slack"
        enabled: true
        failure-threshold: 2

  # External Dependencies
  - name: "CDN Status"
    group: "External"
    url: "https://cdn.example.com/status"
    interval: 60s
    conditions:
      - "[STATUS] == 200"
      - "[BODY] !~ .*error.*"
    alerts:
      - type: "slack"
        enabled: true

# Custom conditions
conditions:
  - name: "api_healthy"
    description: "API is responding correctly"
EOF
```

**Apply final configuration:**

```bash
# Restart Gatus with complete configuration
docker restart gatus

# Verify all endpoints are loaded
curl -s http://localhost:8080/api/v1/endpoints | jq 'length'

# Check dashboard customization
curl -s http://localhost:8080/ | grep -i "Enterprise Uptime Monitor"
```

![Dashboard Customization](./img/dashboard-customization.png)

---

## 🛠️ Troubleshooting Guide

### Common Issues and Solutions

| Problem | Symptoms | Solution |
|---------|----------|----------|
| **Container Won't Start** | `docker ps` shows container restarting | Check logs: `docker logs gatus`, verify config file syntax, ensure volume mounts exist |
| **Web Interface Not Accessible** | `curl http://localhost:8080` returns connection refused | Verify port mapping, check firewall rules, ensure container is running |
| **Configuration Not Loading** | Endpoints not appearing in dashboard | Check YAML syntax, verify file permissions, check container logs for parsing errors |
| **Alerts Not Sending** | No notifications in Slack/email | Verify webhook URLs, check network connectivity, validate alert configuration |
| **High Resource Usage** | Container using excessive CPU/memory | Reduce check intervals, limit number of endpoints, check for infinite loops in conditions |
| **False Positives** | Alerts triggering for working services | Adjust conditions, increase thresholds, check network stability |

### Debugging Commands

```bash
# Check container status and logs
docker ps -a | grep gatus
docker logs gatus
docker logs -f gatus  # Follow logs

# Test configuration syntax
docker exec gatus /gatus validate /config/config.yaml

# Check endpoint health via API
curl -s http://localhost:8080/api/v1/endpoints | jq '.endpoints[] | {name: .name, conditions: .conditions}'

# Monitor resource usage
docker stats gatus

# Test network connectivity
docker exec gatus curl -I https://www.google.com

# Check storage and logs
ls -la data/ logs/
tail -f logs/gatus.log

# Verify webhook URLs (replace with actual webhook)
curl -X POST -H 'Content-type: application/json' --data '{"text":"Test alert"}' https://hooks.slack.com/services/YOUR/WEBHOOK/URL
```

### Common Error Messages

**`Error parsing configuration file`**
- **Cause**: YAML syntax error or invalid configuration
- **Solution**: Validate YAML syntax, check for missing quotes, verify indentation

**`dial tcp: lookup example.com: no such host`**
- **Cause**: DNS resolution issues in container
- **Solution**: Check container networking, verify DNS configuration, test with IP addresses

**`Post "https://hooks.slack.com/...": 404 Not Found`**
- **Cause**: Invalid Slack webhook URL
- **Solution**: Verify webhook URL, regenerate if necessary, check Slack app configuration

---

## 📸 Evidence and Screenshots for Submission

### Required Screenshots

1. **Prerequisites Verification**
   - `evidence-01-docker-version.png` - Docker installation verification
   - `evidence-02-system-resources.png` - Available system resources
   - `evidence-03-network-test.png` - Network connectivity test

2. **Gatus Installation**
   - `evidence-04-docker-pull.png` - Gatus Docker image download
   - `evidence-05-container-running.png` - Gatus container status
   - `evidence-06-initial-config.png` - Initial configuration file

3. **Endpoint Configuration**
   - `evidence-07-multi-endpoint-config.png` - Configuration with multiple endpoints
   - `evidence-08-endpoint-groups.png` - Endpoint groups and organization
   - `evidence-09-custom-conditions.png` - Custom monitoring conditions

4. **Dashboard and Monitoring**
   - `evidence-10-gatus-dashboard.png` - Main Gatus dashboard view
   - `evidence-11-endpoint-status.png` - Individual endpoint status details
   - `evidence-12-historical-data.png` - Historical uptime data
   - `evidence-13-response-times.png` - Response time graphs

5. **Alerting Configuration**
   - `evidence-14-slack-alert-config.png` - Slack alerting configuration
   - `evidence-15-alert-testing.png` - Alert testing with failing endpoint
   - `evidence-16-alert-delivery.png` - Successful alert delivery in Slack
   - `evidence-17-alert-resolution.png` - Alert resolution verification

6. **Advanced Features**
   - `evidence-18-ui-customization.png` - Customized dashboard interface
   - `evidence-19-multiple-groups.png` - Multiple endpoint groups view
   - `evidence-20-performance-metrics.png` - Gatus performance metrics

### Screenshot Naming Convention
All screenshots should be saved in the `img/` directory with descriptive names:
- `evidence-XX-description.png`
- Include terminal prompts, command outputs, and browser views
- Ensure Gatus dashboard, configuration files, and logs are clearly visible
- Capture both successful configurations and troubleshooting steps

---

## 🎓 Key Concepts Learned

### Uptime Monitoring Fundamentals
- **Health Checks**: Automated verification of service availability
- **Response Time Monitoring**: Performance measurement and alerting
- **Status Code Validation**: HTTP status code verification
- **Custom Conditions**: Flexible monitoring rule definition
- **Historical Tracking**: Uptime and performance trend analysis

### Gatus Architecture
- **Configuration-Driven**: YAML-based endpoint and alerting configuration
- **Container-Native**: Docker-based deployment for easy scaling
- **Web Dashboard**: Built-in UI for monitoring visualization
- **Multiple Alert Types**: Slack, email, and webhook notifications
- **Persistent Storage**: SQLite database for historical data

### Monitoring Best Practices
- **Redundant Checks**: Multiple conditions for robust monitoring
- **Appropriate Intervals**: Balance between detection speed and resource usage
- **Alert Thresholds**: Configurable failure and success thresholds
- **Group Organization**: Logical grouping of related services
- **Custom Dashboards**: Tailored monitoring views for different teams

---

## 🔧 Advanced Configuration Options

### Multiple Notification Channels
```yaml
alerting:
  slack:
    webhook-url: "https://hooks.slack.com/services/..."
    default-alert:
      enabled: true
  email:
    from: "alerts@example.com"
    host: "smtp.gmail.com"
    port: 587
    username: "alerts@example.com"
    password: "app-password"
  webhook:
    url: "https://your-webhook-endpoint.com/alerts"
    method: "POST"
    headers:
      Authorization: "Bearer token123"
```

### Custom Conditions and Validations
```yaml
conditions:
  - "[STATUS] == 200"
  - "[RESPONSE_TIME] < 1000"
  - "[BODY] !~ .*error.*"
  - "[HEADER] Content-Type == 'application/json'"
  - "[JSON_PATH] $.status == 'healthy'"
  - "[CERTIFICATE_EXPIRY] > 30"
```

### Load Balancing and High Availability
```yaml
# For multiple Gatus instances
external-configuration:
  - url: "https://gatus-1.example.com/config.yaml"
  - url: "https://gatus-2.example.com/config.yaml"
```

### Custom Metrics and Export
```yaml
# Enable Prometheus metrics export
metrics: true
web:
  address: "0.0.0.0:8080"

# Custom metrics endpoint
endpoints:
  - name: "Prometheus Metrics"
    url: "https://prometheus.example.com/metrics"
    interval: 60s
    conditions:
      - "[STATUS] == 200"
```

---

## ✅ Project Checklist

- [ ] **Docker environment verified** (installation, resources, connectivity)
- [ ] **Gatus container deployed** with proper volume mounts and networking
- [ ] **Multiple endpoints configured** across different service types
- [ ] **Custom conditions implemented** for various monitoring scenarios
- [ ] **Alerting configured** with Slack/email notifications
- [ ] **Alert functionality tested** (trigger, delivery, resolution)
- [ ] **Dashboard customized** with branding and navigation
- [ ] **Performance monitoring verified** (response times, uptime tracking)
- [ ] **All screenshots captured** for evidence
- [ ] **Troubleshooting documented** (if applicable)

---

## 🚀 Next Steps

With uptime monitoring mastered, you can now:

1. **Multi-Environment Monitoring**: Deploy Gatus across dev/staging/production
2. **API Gateway Integration**: Monitor microservices behind API gateways
3. **Database Monitoring**: Add health checks for database connectivity
4. **Container Orchestration**: Deploy Gatus in Kubernetes clusters
5. **Custom Exporters**: Create custom monitoring for internal services
6. **SLA Reporting**: Generate uptime reports for stakeholders

---

## 🏆 Project Outcomes

By completing this project, you have:

✅ **Deployed comprehensive uptime monitoring** using Gatus for multiple service types
✅ **Configured automated alerting** with Slack/email notifications for downtime events
✅ **Implemented custom conditions** for flexible health check validation
✅ **Created personalized dashboards** for monitoring visualization and reporting
✅ **Tested monitoring effectiveness** with simulated failures and alert verification
✅ **Gained practical experience** with production-grade uptime monitoring tools
✅ **Documented the entire process** for submission and review

**Congratulations on mastering uptime monitoring with Gatus!** 🎉

This project demonstrates your ability to implement critical service availability monitoring, making you ready for DevOps reliability engineering and site reliability engineering roles.

For questions or issues, refer to the troubleshooting section or consult the official Gatus documentation.

---

## 📚 Additional Resources

- **Gatus Official Documentation**: [https://gatus.io/](https://gatus.io/)
- **Gatus GitHub Repository**: [https://github.com/TwiN/gatus](https://github.com/TwiN/gatus)
- **Docker Installation Guide**: [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/)
- **Slack Webhook Setup**: [https://api.slack.com/messaging/webhooks](https://api.slack.com/messaging/webhooks)
- **Uptime Monitoring Best Practices**: [https://www.pingdom.com/resources/uptime-monitoring-best-practices/](https://www.pingdom.com/resources/uptime-monitoring-best-practices/)
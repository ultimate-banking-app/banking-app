# Banking Application - Monitoring Guide

## 🔍 What is Monitoring?

**Monitoring** is the practice of observing and tracking the performance, health, and behavior of applications and infrastructure in real-time to ensure optimal operation and quick issue detection.

### **Why Monitor Banking Applications?**
- **Uptime**: Ensure 99.9%+ availability for critical financial services
- **Performance**: Detect slow transactions that impact user experience
- **Security**: Monitor for suspicious activities and potential breaches
- **Compliance**: Track audit trails for regulatory requirements
- **Capacity**: Predict scaling needs before performance degrades

## 🎯 Current Service Monitoring

### **Service Health Endpoints:**
```bash
# API Gateway (8090)
curl http://localhost:8090/actuator/health

# Auth Service (8081) 
curl http://localhost:8081/actuator/health

# Account Service (8084)
curl http://localhost:8084/actuator/health

# Payment Service (8083)
curl http://localhost:8083/actuator/health
```

### **Swagger Documentation:**
- Account Service: http://localhost:8084/swagger-ui.html
- Payment Service: http://localhost:8083/swagger-ui.html
- API Gateway: http://localhost:8090/swagger-ui.html

### **Banking UI Dashboard:**
- Real-time service status monitoring
- Open: `banking-ui.html` in browser
- Auto-refresh every 30 seconds

### **Our 4-Layer Monitoring Architecture:**

```
┌─────────────────────────────────────────────────────────┐
│                    Alerting Layer                       │
│              Slack + Email + PagerDuty                 │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│                 Visualization Layer                     │
│                     Grafana                             │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│                  Metrics Layer                          │
│                   Prometheus                            │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│                Application Layer                        │
│    Banking Services + Spring Boot Actuator             │
└─────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start - Run Monitoring Stack

### **1. Start Complete Monitoring Infrastructure**

```bash
# Navigate to project directory
cd banking-app

# Start monitoring stack
docker-compose -f jenkins/docker-compose.jenkins.yml up -d grafana prometheus

# Verify services are running
docker ps | grep -E "(grafana|prometheus)"

# Expected output:
# banking-grafana      grafana/grafana:latest    "0.0.0.0:3000->3000/tcp"
# banking-prometheus   prom/prometheus:latest    "0.0.0.0:9090->9090/tcp"
```

### **2. Access Monitoring Dashboards**

```bash
# Grafana Dashboard
open http://localhost:3000
# Login: admin / admin123

# Prometheus Metrics
open http://localhost:9090

# SonarQube Quality Metrics
open http://localhost:9000
```

### **3. Start Banking Services with Monitoring**

```bash
# Build and start services with monitoring enabled
./scripts/build-optimized.sh
./start-all-services.sh

# Verify service health endpoints
for port in 8080 8081 8082 8083 8084 8085 8086 8087 8088 8089; do
  echo "Checking service on port $port..."
  curl -s http://localhost:$port/actuator/health | jq '.status'
done
```

## 📈 Monitoring Components

### **1. Application Metrics (Spring Boot Actuator)**

#### **Health Checks**
```bash
# Check overall application health
curl http://localhost:8082/actuator/health

# Response:
{
  "status": "UP",
  "components": {
    "db": {"status": "UP"},
    "diskSpace": {"status": "UP"},
    "ping": {"status": "UP"}
  }
}
```

#### **Performance Metrics**
```bash
# Get application metrics
curl http://localhost:8082/actuator/metrics

# Specific metric (HTTP requests)
curl http://localhost:8082/actuator/metrics/http.server.requests

# JVM memory usage
curl http://localhost:8082/actuator/metrics/jvm.memory.used
```

#### **Prometheus Endpoint**
```bash
# Prometheus-formatted metrics
curl http://localhost:8082/actuator/prometheus

# Sample output:
# http_server_requests_seconds_count{method="GET",status="200",uri="/accounts"} 45.0
# jvm_memory_used_bytes{area="heap",id="G1 Eden Space"} 1.048576E7
```

### **2. Prometheus Configuration**

#### **Service Discovery**
```yaml
# prometheus.yml
scrape_configs:
  - job_name: 'banking-services'
    static_configs:
      - targets: 
        - 'localhost:8080'  # api-gateway
        - 'localhost:8081'  # auth-service
        - 'localhost:8082'  # account-service
        # ... all 10 services
    metrics_path: '/actuator/prometheus'
    scrape_interval: 15s
```

#### **Key Metrics Collected**
- **HTTP Requests**: Response times, status codes, throughput
- **JVM Metrics**: Memory usage, garbage collection, threads
- **Database**: Connection pool, query performance
- **Custom Business Metrics**: Account creations, transactions, balances

### **3. Grafana Dashboards**

#### **Pre-built Dashboard Queries**

**Service Health Overview:**
```promql
# Service availability
up{job="banking-services"}

# HTTP request rate
rate(http_server_requests_seconds_count[5m])

# Average response time
rate(http_server_requests_seconds_sum[5m]) / rate(http_server_requests_seconds_count[5m])
```

**Performance Monitoring:**
```promql
# 95th percentile response time
histogram_quantile(0.95, rate(http_server_requests_seconds_bucket[5m]))

# Error rate
rate(http_server_requests_seconds_count{status=~"5.."}[5m]) / rate(http_server_requests_seconds_count[5m])

# JVM memory usage
jvm_memory_used_bytes{area="heap"} / jvm_memory_max_bytes{area="heap"}
```

## 🔧 Setup Instructions

### **1. Configure Application Monitoring**

#### **Add to each service's `application.yml`:**
```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: always
  metrics:
    export:
      prometheus:
        enabled: true
    tags:
      application: ${spring.application.name}
      environment: ${DEPLOY_ENV:local}
```

#### **Add Micrometer Dependencies (already in parent POM):**
```xml
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```

### **2. Custom Business Metrics**

#### **Add to Service Classes:**
```java
@RestController
public class AccountController {
    
    private final MeterRegistry meterRegistry;
    private final Counter accountCreationCounter;
    private final Timer accountCreationTimer;
    
    public AccountController(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
        this.accountCreationCounter = Counter.builder("accounts.created")
            .description("Number of accounts created")
            .register(meterRegistry);
        this.accountCreationTimer = Timer.builder("accounts.creation.time")
            .description("Time taken to create account")
            .register(meterRegistry);
    }
    
    @PostMapping("/accounts")
    public Account createAccount(@RequestBody CreateAccountRequest request) {
        return accountCreationTimer.recordCallable(() -> {
            Account account = accountService.createAccount(request);
            accountCreationCounter.increment();
            return account;
        });
    }
}
```

### **3. Database Monitoring**

#### **HikariCP Metrics (Auto-configured):**
```yaml
spring:
  datasource:
    hikari:
      register-mbeans: true  # Enable JMX metrics
```

#### **Available Database Metrics:**
- `hikaricp.connections.active` - Active connections
- `hikaricp.connections.idle` - Idle connections
- `hikaricp.connections.pending` - Pending connection requests
- `hikaricp.connections.timeout` - Connection timeouts

## 📊 Grafana Dashboard Setup

### **1. Import Banking Application Dashboard**

```bash
# Create dashboard JSON
cat > banking-dashboard.json << 'EOF'
{
  "dashboard": {
    "title": "Banking Application Monitoring",
    "panels": [
      {
        "title": "Service Health",
        "type": "stat",
        "targets": [
          {
            "expr": "up{job=\"banking-services\"}",
            "legendFormat": "{{instance}}"
          }
        ]
      },
      {
        "title": "HTTP Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_server_requests_seconds_count[5m])",
            "legendFormat": "{{application}} - {{method}} {{uri}}"
          }
        ]
      },
      {
        "title": "Response Time (95th percentile)",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_server_requests_seconds_bucket[5m]))",
            "legendFormat": "{{application}}"
          }
        ]
      }
    ]
  }
}
EOF

# Import via Grafana API
curl -X POST http://admin:admin123@localhost:3000/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d @banking-dashboard.json
```

### **2. Key Dashboard Panels**

#### **Service Overview Panel:**
- **Service Status**: Up/Down indicators for all 10 services
- **Request Volume**: Requests per second by service
- **Error Rate**: 4xx/5xx error percentage
- **Response Time**: Average and 95th percentile

#### **Performance Panel:**
- **JVM Memory**: Heap usage across services
- **Database Connections**: Active/idle connection counts
- **Garbage Collection**: GC frequency and duration
- **Thread Pools**: Active threads and queue sizes

#### **Business Metrics Panel:**
- **Account Operations**: Creations, updates, deletions
- **Transaction Volume**: Payments, transfers, deposits, withdrawals
- **Balance Inquiries**: Query frequency and response times
- **Authentication**: Login attempts, success/failure rates

## 🚨 Alerting Configuration

### **1. Prometheus Alerting Rules**

```yaml
# alerts.yml
groups:
  - name: banking-application
    rules:
      - alert: ServiceDown
        expr: up{job="banking-services"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Banking service {{ $labels.instance }} is down"
          
      - alert: HighErrorRate
        expr: rate(http_server_requests_seconds_count{status=~"5.."}[5m]) / rate(http_server_requests_seconds_count[5m]) > 0.05
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High error rate on {{ $labels.application }}"
          
      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(http_server_requests_seconds_bucket[5m])) > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High response time on {{ $labels.application }}"
```

### **2. Notification Channels**

#### **Slack Integration:**
```bash
# Add to Grafana notification channels
curl -X POST http://admin:admin123@localhost:3000/api/alert-notifications \
  -H "Content-Type: application/json" \
  -d '{
    "name": "banking-alerts",
    "type": "slack",
    "settings": {
      "url": "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK",
      "channel": "#banking-alerts",
      "title": "Banking Application Alert"
    }
  }'
```

## 🔍 Monitoring Checklist

### **Application Health:**
- [ ] All 10 services responding to health checks
- [ ] Database connections healthy
- [ ] JVM memory usage < 80%
- [ ] No critical errors in logs

### **Performance Metrics:**
- [ ] Response times < 500ms (95th percentile)
- [ ] Error rate < 1%
- [ ] Throughput meeting SLA requirements
- [ ] Database query performance optimal

### **Business Metrics:**
- [ ] Account operations tracking
- [ ] Transaction volume monitoring
- [ ] Authentication success rates
- [ ] Balance inquiry performance

### **Infrastructure:**
- [ ] CPU usage < 70%
- [ ] Memory usage < 80%
- [ ] Disk space > 20% free
- [ ] Network connectivity stable

## 📋 Troubleshooting

### **Common Issues:**

#### **1. Metrics Not Appearing**
```bash
# Check actuator endpoints
curl http://localhost:8082/actuator/health
curl http://localhost:8082/actuator/prometheus

# Verify Prometheus targets
curl http://localhost:9090/api/v1/targets
```

#### **2. Grafana Connection Issues**
```bash
# Check Prometheus data source
curl http://localhost:3000/api/datasources

# Test Prometheus connectivity from Grafana
docker exec banking-grafana curl http://prometheus:9090/api/v1/query?query=up
```

#### **3. High Memory Usage**
```bash
# Check JVM metrics
curl http://localhost:8082/actuator/metrics/jvm.memory.used

# Analyze garbage collection
curl http://localhost:8082/actuator/metrics/jvm.gc.pause
```

## 🎯 Monitoring Best Practices

### **1. Golden Signals (SRE)**
- **Latency**: How long requests take
- **Traffic**: How many requests per second
- **Errors**: Rate of failed requests
- **Saturation**: How "full" the service is

### **2. Banking-Specific Metrics**
- **Transaction Success Rate**: Critical for financial operations
- **Account Balance Accuracy**: Data consistency monitoring
- **Authentication Security**: Failed login attempts, suspicious patterns
- **Regulatory Compliance**: Audit trail completeness

### **3. Alerting Strategy**
- **Immediate**: Service down, high error rates
- **Warning**: Performance degradation, resource usage
- **Info**: Deployment notifications, maintenance windows

---

## 🚀 Quick Commands Summary

```bash
# Start monitoring stack
docker-compose -f jenkins/docker-compose.jenkins.yml up -d grafana prometheus

# Access dashboards
open http://localhost:3000  # Grafana
open http://localhost:9090  # Prometheus

# Check service health
curl http://localhost:8082/actuator/health

# View metrics
curl http://localhost:8082/actuator/prometheus

# Start all banking services
./start-all-services.sh
```

**Your banking application now has enterprise-grade monitoring with real-time visibility into performance, health, and business metrics!** 📊🏦

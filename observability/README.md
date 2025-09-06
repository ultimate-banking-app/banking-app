# 📊 Banking Application Observability Stack

## 🎯 Overview

Complete observability stack for the Banking Application including metrics, logging, tracing, visualization, and custom business metrics with automated alerting.

## 📁 Directory Structure

```
observability/
├── namespace.yaml                    # Namespace and RBAC
├── prometheus/
│   ├── prometheus.yaml              # Metrics collection
│   └── custom-metrics.yaml         # Custom rules and alerts
├── grafana/
│   ├── grafana.yaml                 # Metrics visualization
│   └── banking-dashboards.yaml     # Banking-specific dashboards
├── jaeger/
│   └── jaeger.yaml                  # Distributed tracing
├── loki/
│   └── loki.yaml                    # Log aggregation
├── ingress.yaml                     # External access
├── kustomization.yaml               # Kustomize config
├── README.md                        # This documentation
└── CUSTOM-METRICS-IMPLEMENTATION.md # Implementation guide
```

## 🚀 Quick Deployment

```bash
# Deploy observability stack
kubectl apply -k k8s/observability

# Check deployment status
kubectl get pods -n observability
kubectl get services -n observability
kubectl get ingress -n observability
```

## 📊 Components

### 🔍 Prometheus (Metrics Collection)
- **Port**: 9090
- **Purpose**: Metrics collection, custom rules, and alerting
- **Targets**: Banking services with `/actuator/prometheus` endpoint
- **Custom Rules**: Business metrics aggregation and alerting
- **Retention**: 200 hours
- **Access**: http://prometheus.local

### 📈 Grafana (Visualization)
- **Port**: 3000
- **Purpose**: Metrics visualization and dashboards
- **Credentials**: admin/admin123
- **Datasources**: Prometheus and Loki (auto-configured)
- **Dashboards**: Banking Business Metrics, Technical Metrics
- **Access**: http://grafana.local

### 🔗 Jaeger (Distributed Tracing)
- **Query Port**: 16686
- **Collector Port**: 14268
- **Purpose**: Distributed tracing across microservices
- **Storage**: In-memory (50,000 traces)
- **Access**: http://jaeger.local

### 📝 Loki + Promtail (Logging)
- **Loki Port**: 3100
- **Purpose**: Log aggregation and querying
- **Collection**: Promtail DaemonSet
- **Storage**: Filesystem (temporary)
- **Integration**: Grafana datasource

## 📊 Custom Banking Metrics

### 🏦 Business Metrics
- `banking_login_attempts_total` - Login attempts by status
- `banking_transactions_total` - Transactions by type and status
- `banking_account_balance` - Current account balances by type
- `banking_payments_total` - Payments by type and status
- `banking_payment_amount_total` - Payment amounts by type

### ⚡ Technical Metrics
- `banking_login_duration_seconds` - Login processing time
- `banking_payment_processing_seconds` - Payment processing time
- `banking_gateway_requests_total` - Gateway request counts
- `banking_circuit_breaker_events_total` - Circuit breaker events
- `banking_pending_payments` - Current pending payments count

### 📈 Derived Metrics (Recording Rules)
- `banking:transaction_rate_5m` - Transaction rate over 5 minutes
- `banking:transaction_success_rate_5m` - Transaction success rate
- `banking:account_balance_total` - Total balances by account type
- `banking:payment_volume_5m` - Payment volume by type
- `banking:login_success_rate_5m` - Login success rate
- `banking:api_error_rate_5m` - API error rate by service

## 🚨 Automated Alerts

### 🔴 Critical Alerts
- **Service Down**: Service unavailable for > 1 minute
- **Low Account Balance**: Account balance < $100

### 🟡 Warning Alerts
- **High Transaction Failure Rate**: Success rate < 95% for 2 minutes
- **High Login Failure Rate**: Success rate < 90% for 5 minutes
- **High API Error Rate**: Error rate > 5% for 3 minutes

## 📊 Dashboards

### 🏦 Banking Business Metrics Dashboard
- **Transaction Rate**: Real-time transaction processing rate
- **Transaction Success Rate**: Success percentage with thresholds
- **Payment Volume by Type**: Pie chart of payment types
- **Account Balances by Type**: Bar gauge of account balances
- **Login Success Rate**: Time series of login success trends
- **API Error Rate**: Error rates by service

### ⚡ Banking Technical Metrics Dashboard
- **Service Health**: Up/down status of all services
- **HTTP Request Rate**: Request rates by service
- **Response Time (95th percentile)**: Performance metrics
- **JVM Memory Usage**: Heap memory utilization
- **Database Connections**: HikariCP connection pool metrics
- **Garbage Collection Time**: GC performance metrics

## 🔧 Configuration

### Service Annotations
Add to banking services for Prometheus scraping:
```yaml
metadata:
  annotations:
    prometheus.io/scrape: 'true'
    prometheus.io/port: '8081'
    prometheus.io/path: '/actuator/prometheus'
```

### Application Properties
Add to Spring Boot services:
```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    prometheus:
      enabled: true
  metrics:
    export:
      prometheus:
        enabled: true
    tags:
      application: ${spring.application.name}
      environment: ${SPRING_PROFILES_ACTIVE:local}
```

## 🔍 Monitoring Queries

### Business Metrics Queries
```promql
# Transaction success rate
banking:transaction_success_rate_5m * 100

# Payment volume by type
sum(banking:payment_volume_5m) by (payment_type)

# Account balances by type
banking:account_balance_total

# Login failure rate
(1 - banking:login_success_rate_5m) * 100
```

### Technical Metrics Queries
```promql
# Service availability
up{job="banking-services"}

# Request rate by service
sum(rate(http_requests_total{job="banking-services"}[5m])) by (kubernetes_name)

# Error rate by service
banking:api_error_rate_5m * 100

# JVM memory usage
jvm_memory_used_bytes{area="heap"} / jvm_memory_max_bytes{area="heap"} * 100
```

### LogQL Queries (Loki)
```logql
# All banking service logs
{namespace=~"banking-.*"}

# Transaction-related logs
{namespace=~"banking-.*"} |= "transaction"

# Error logs only
{namespace=~"banking-.*"} |= "ERROR"

# Payment processing logs
{namespace=~"banking-.*", app="payment-service"} |= "payment" |= "processed"
```

## 🔧 Access URLs

After deployment, access the observability tools:

```bash
# Add to /etc/hosts
echo "127.0.0.1 grafana.local prometheus.local jaeger.local" >> /etc/hosts

# Port forward if ingress not available
kubectl port-forward -n observability svc/grafana 3000:3000
kubectl port-forward -n observability svc/prometheus 9090:9090
kubectl port-forward -n observability svc/jaeger-query 16686:16686
```

## 📊 Resource Usage

| Component | CPU Request | Memory Request | CPU Limit | Memory Limit |
|-----------|-------------|----------------|-----------|--------------|
| Prometheus | 200m | 1000Mi | 1000m | 2000Mi |
| Grafana | 250m | 750Mi | 500m | 1Gi |
| Jaeger | 100m | 128Mi | 500m | 512Mi |
| Loki | 100m | 128Mi | 500m | 512Mi |
| Promtail | 50m | 64Mi | 200m | 128Mi |

## 🛠️ Implementation Guide

### 1. Add Dependencies
Add Micrometer and Actuator dependencies to each service:
```xml
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

### 2. Implement Custom Metrics
See `CUSTOM-METRICS-IMPLEMENTATION.md` for detailed implementation examples.

### 3. Configure Applications
Update `application.yml` with metrics configuration.

### 4. Deploy Observability Stack
```bash
kubectl apply -k k8s/observability
```

### 5. Verify Metrics Collection
```bash
# Check Prometheus targets
curl http://prometheus.local/targets

# Check custom metrics
curl http://auth-service:8081/actuator/prometheus | grep banking_
```

## 🚨 Alerting Integration

### AlertManager Configuration
```yaml
# Add to AlertManager config
route:
  group_by: ['alertname', 'service']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'banking-alerts'

receivers:
- name: 'banking-alerts'
  slack_configs:
  - api_url: 'YOUR_SLACK_WEBHOOK_URL'
    channel: '#banking-alerts'
    title: 'Banking Alert: {{ .GroupLabels.alertname }}'
    text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'
```

---

**📊 This enhanced observability stack provides comprehensive business and technical monitoring for the Banking Application with custom metrics, automated alerting, and detailed dashboards for operational excellence.**

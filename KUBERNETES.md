# ☸️ Banking Application Kubernetes Guide

## 🎯 Overview

Complete Kubernetes deployment guide for the Banking Application with base manifests, environment overlays, observability stack with custom business metrics, and ArgoCD GitOps deployment.

## 📁 Directory Structure

```
banking-app/
├── k8s/                            # Kubernetes manifests
│   ├── base/                       # Base Kubernetes manifests
│   ├── overlays/                   # Environment overlays
│   └── argocd/                     # GitOps deployment
├── observability/                  # Monitoring stack
│   ├── prometheus/                 # Metrics with custom rules
│   ├── grafana/                    # Dashboards with banking metrics
│   ├── jaeger/                     # Tracing
│   └── loki/                       # Logging
└── [other directories]
```

## 🚀 Quick Start

### Prerequisites
```bash
kubectl version --client
kustomize version
```

### Deploy Application
```bash
# Development
kubectl apply -k k8s/overlays/dev

# Production
kubectl apply -k k8s/overlays/prod

# Observability with custom metrics
kubectl apply -k observability

# ArgoCD GitOps
kubectl apply -k k8s/argocd
```

### Verify Deployment
```bash
kubectl get pods -n banking-dev
kubectl get services -n banking-dev
kubectl get ingress -n banking-dev
```

## 🏗️ Architecture

### 🔐 Backend Services
- **Auth Service** (8081): JWT authentication with login metrics
- **Account Service** (8084): Account management with transaction metrics
- **Payment Service** (8083): Payment processing with payment metrics
- **API Gateway** (8090): Request routing with gateway metrics

### 🎨 Frontend
- **Banking UI** (80): Vue.js application

### 🗄️ Database
- **PostgreSQL** (5432): Persistent data storage

### 📊 Observability
- **Prometheus**: Metrics collection with custom banking rules
- **Grafana**: Visualization with banking-specific dashboards
- **Jaeger**: Distributed tracing
- **Loki**: Log aggregation

### 🚀 GitOps
- **ArgoCD**: Automated deployment management
- **Applications**: Multi-environment deployment
- **Projects**: Banking-specific project isolation

## 🔧 Configuration

### Environment Variables
```yaml
# Backend services
SPRING_PROFILES_ACTIVE: k8s
SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/banking_db
AUTH_SERVICE_URL: http://auth-service:8081
MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE: health,info,metrics,prometheus

# Frontend
API_GATEWAY_URL: http://api-gateway:8090
```

### Secrets
```yaml
# Database credentials (base64 encoded)
postgres-secret:
  username: YmFua2luZ191c2Vy  # banking_user
  password: YmFua2luZ19wYXNz  # banking_pass

# JWT signing key
jwt-secret:
  secret: bXlTZWNyZXRLZXlGb3JKV1Q=  # mySecretKeyForJWT
```

### Prometheus Annotations
```yaml
# Service-level annotations for metrics scraping
metadata:
  annotations:
    prometheus.io/scrape: 'true'
    prometheus.io/port: '8081'
    prometheus.io/path: '/actuator/prometheus'
```

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

### 📈 Derived Metrics (Recording Rules)
- `banking:transaction_rate_5m` - Transaction rate over 5 minutes
- `banking:transaction_success_rate_5m` - Transaction success rate
- `banking:account_balance_total` - Total balances by account type
- `banking:payment_volume_5m` - Payment volume by type
- `banking:login_success_rate_5m` - Login success rate
- `banking:api_error_rate_5m` - API error rate by service

### 🚨 Automated Alerts
- **High Transaction Failure Rate**: Success rate < 95%
- **Low Account Balance**: Balance < $100
- **High Login Failure Rate**: Success rate < 90%
- **Service Down**: Service unavailable
- **High API Error Rate**: Error rate > 5%

## 📊 Resource Allocation

### Development Environment
| Service | Replicas | CPU Request | Memory Request | CPU Limit | Memory Limit |
|---------|----------|-------------|----------------|-----------|--------------|
| Auth | 1 | 50m | 128Mi | 200m | 256Mi |
| Account | 1 | 50m | 128Mi | 200m | 256Mi |
| Payment | 1 | 50m | 128Mi | 200m | 256Mi |
| Gateway | 1 | 100m | 256Mi | 500m | 512Mi |
| UI | 1 | 50m | 64Mi | 200m | 128Mi |
| Database | 1 | 100m | 256Mi | 500m | 512Mi |

### Production Environment
| Service | Replicas | CPU Request | Memory Request | CPU Limit | Memory Limit |
|---------|----------|-------------|----------------|-----------|--------------|
| Auth | 3 | 200m | 512Mi | 1000m | 1Gi |
| Account | 3 | 200m | 512Mi | 1000m | 1Gi |
| Payment | 3 | 200m | 512Mi | 1000m | 1Gi |
| Gateway | 2 | 100m | 256Mi | 500m | 512Mi |
| UI | 2 | 50m | 64Mi | 200m | 128Mi |
| Database | 1 | 100m | 256Mi | 500m | 512Mi |

## 🔒 Security

### RBAC
```yaml
# Service accounts with minimal permissions
prometheus: cluster-wide read access for metrics
promtail: pod and log read access
argocd: deployment and application management
```

### Network Policies
```yaml
# Backend services isolation
- Backend services can communicate with each other
- Database access restricted to backend services only
- Frontend only accessible through ingress
- Observability namespace can scrape metrics
```

### Secrets Management
```yaml
# Kubernetes secrets for sensitive data
database credentials, JWT keys
# Environment-specific secret values
# ArgoCD repository credentials
```

## 📊 Monitoring

### Metrics (Prometheus)
```yaml
# Service discovery with custom rules
kubernetes_sd_configs with service annotations
# Custom banking metrics collection
/actuator/prometheus on backend services
# Business and technical alerting rules
# Retention: 200 hours of metrics data
```

### Dashboards (Grafana)
```yaml
# Banking-specific dashboards
- Banking Business Metrics Dashboard
- Banking Technical Metrics Dashboard
# Real-time monitoring
- Transaction rates and success rates
- Payment volumes and account balances
- Service health and performance metrics
# Access: grafana.local (admin/admin123)
```

### Tracing (Jaeger)
```yaml
# Distributed tracing
All-in-one deployment
50,000 trace limit
# Access: jaeger.local
```

### Logging (Loki)
```yaml
# Log aggregation
Promtail DaemonSet collection
Kubernetes pod logs
# Integration: Grafana datasource
```

## 🚀 GitOps with ArgoCD

### Applications
```yaml
# Banking Development
source: k8s/overlays/dev
targetRevision: main
syncPolicy: automated (prune + self-heal)

# Banking Production
source: k8s/overlays/prod
targetRevision: v1.0.0 (tags)
syncPolicy: manual

# Observability Stack
source: observability
targetRevision: main
syncPolicy: automated (prune + self-heal)
```

### Project Security
```yaml
# Banking project with RBAC
banking-admin: Full access to banking applications
banking-developer: Sync and view permissions
banking-viewer: Read-only access
```

## 🛠️ Operations

### Deployment Commands
```bash
# Apply configurations
kubectl apply -k k8s/overlays/dev
kubectl apply -k k8s/overlays/prod
kubectl apply -k observability
kubectl apply -k k8s/argocd

# Update images
kubectl set image deployment/auth-service auth-service=banking/auth-service:v1.1.0 -n banking-dev

# Scale services
kubectl scale deployment auth-service --replicas=3 -n banking-prod

# Rolling updates
kubectl rollout restart deployment/auth-service -n banking-dev
kubectl rollout status deployment/auth-service -n banking-dev
```

### Monitoring Commands
```bash
# Check custom metrics
kubectl exec deployment/auth-service -n banking-dev -- curl localhost:8081/actuator/prometheus | grep banking_

# View business metrics
kubectl port-forward -n observability svc/grafana 3000:3000
# Access: http://localhost:3000 (admin/admin123)

# Check Prometheus targets
kubectl port-forward -n observability svc/prometheus 9090:9090
# Access: http://localhost:9090/targets
```

### Troubleshooting
```bash
# Check pod status
kubectl get pods -n banking-dev
kubectl describe pod <pod-name> -n banking-dev

# View logs
kubectl logs deployment/auth-service -n banking-dev -f

# Debug networking
kubectl exec -it deployment/auth-service -n banking-dev -- curl http://postgres:5432

# Check metrics endpoint
kubectl exec deployment/auth-service -n banking-dev -- curl localhost:8081/actuator/prometheus

# Port forwarding
kubectl port-forward service/banking-ui 3000:80 -n banking-dev
```

### Health Checks
```bash
# Service health
kubectl exec deployment/auth-service -n banking-dev -- curl localhost:8081/actuator/health

# Database connectivity
kubectl exec deployment/postgres -n banking-dev -- pg_isready -U banking_user

# Ingress status
kubectl get ingress -n banking-dev

# ArgoCD applications
kubectl get applications -n argocd
```

## 🔄 CI/CD Integration

### Jenkins
```groovy
stage('Deploy to K8s') {
    steps {
        sh """
            kubectl apply -k k8s/overlays/\${env.ENVIRONMENT}
        """
    }
}
```

### GitLab CI
```yaml
deploy:
  script:
    - kubectl apply -k k8s/overlays/${CI_ENVIRONMENT_NAME}
  environment:
    name: ${CI_ENVIRONMENT_NAME}
```

### GitHub Actions
```yaml
- name: Deploy to Kubernetes
  run: |
    kubectl apply -k k8s/overlays/${{ github.event.inputs.environment }}
```

### ArgoCD GitOps
```yaml
# Automated deployment via Git commits
- Push to main → Auto-sync to development
- Create tag → Manual sync to production
- Update observability → Auto-sync monitoring
```

## 📚 Best Practices

### Resource Management
- Set appropriate resource requests and limits
- Use horizontal pod autoscaling for production
- Monitor resource usage with custom metrics
- Implement pod disruption budgets

### Security
- Use least-privilege RBAC policies
- Implement network policies for isolation
- Rotate secrets regularly
- Scan images for vulnerabilities

### Reliability
- Configure comprehensive health checks
- Use multiple replicas for critical services
- Implement graceful shutdown
- Plan for disaster recovery

### Monitoring
- Monitor business and technical metrics
- Set up automated alerting
- Use distributed tracing for debugging
- Aggregate logs centrally
- Create custom dashboards for business KPIs

### GitOps
- Use ArgoCD for automated deployments
- Implement proper RBAC for GitOps
- Monitor application sync status
- Plan rollback strategies

---

**☸️ This Kubernetes setup provides production-ready deployment with comprehensive monitoring including custom business metrics, security, operational capabilities, and GitOps automation for the Banking Application.**

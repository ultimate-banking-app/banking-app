# 🚀 Banking Application Deployment Guide

## 🎯 Overview

This guide covers all deployment scenarios for the Banking Application, from local development to production Kubernetes clusters, including CI/CD pipeline configurations and comprehensive observability.

## 🏠 Local Development Deployment

### 📋 Prerequisites
```bash
# Required Software
Java 17+                    # OpenJDK or Oracle JDK
Node.js 18+                # LTS version recommended
Maven 3.8+                 # Build tool for Java services
Docker 20.10+              # Container runtime
Docker Compose 2.0+        # Multi-container orchestration
PostgreSQL 13+             # Database (or use Docker)
```

### 🚀 Quick Start
```bash
# 1. Clone repository
git clone <repository-url>
cd banking-app

# 2. Start database
docker-compose -f docker-compose-db.yml up -d

# 3. Build all services
mvn clean install -DskipTests

# 4. Start backend services
./start-services.sh

# 5. Start frontend
cd banking-ui
npm install
npm run dev

# 6. Access application
open http://localhost:3000
```

### 🔧 Manual Service Startup
```bash
# Start each service individually
cd auth-service && mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Dserver.port=8081" &
cd account-service && mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Dserver.port=8084" &
cd payment-service && mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Dserver.port=8083" &
cd api-gateway && mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Dserver.port=8090" &
```

## 🐳 Docker Deployment

### 📦 Single-Host Docker Compose
```bash
# Build all images
docker-compose build

# Start complete stack
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Stop stack
docker-compose down
```

### 🔧 Docker Compose Configuration
```yaml
# docker-compose.yml
version: '3.8'
services:
  postgres:
    image: postgres:13
    environment:
      POSTGRES_DB: banking_db
      POSTGRES_USER: banking_user
      POSTGRES_PASSWORD: banking_pass
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  auth-service:
    build: ./auth-service
    ports:
      - "8081:8081"
    depends_on:
      - postgres
      - redis
    environment:
      SPRING_PROFILES_ACTIVE: docker
      DATABASE_URL: jdbc:postgresql://postgres:5432/banking_db

  account-service:
    build: ./account-service
    ports:
      - "8084:8084"
    depends_on:
      - postgres
      - redis

  payment-service:
    build: ./payment-service
    ports:
      - "8083:8083"
    depends_on:
      - postgres
      - redis

  api-gateway:
    build: ./api-gateway
    ports:
      - "8090:8090"
    depends_on:
      - auth-service
      - account-service
      - payment-service

  banking-ui:
    build: ./banking-ui
    ports:
      - "3000:80"
    depends_on:
      - api-gateway

volumes:
  postgres_data:
```

## ☸️ Kubernetes Deployment

### 🏗️ Prerequisites
```bash
# Kubernetes cluster (local or cloud)
kubectl version --client
helm version

# Container registry access
docker login ghcr.io
# or
docker login registry.gitlab.com
```

### 📦 Helm Deployment
```bash
# Add Helm repository (if using external charts)
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Install with Helm
helm install banking-app ./helm/banking-app \
  --namespace banking \
  --create-namespace \
  --values values-dev.yaml

# Upgrade deployment
helm upgrade banking-app ./helm/banking-app \
  --namespace banking \
  --values values-prod.yaml

# Check status
helm status banking-app -n banking
kubectl get pods -n banking
```

### 🔧 Environment-Specific Values

#### Development (values-dev.yaml)
```yaml
global:
  environment: dev
  imageTag: latest
  registry: ghcr.io/your-org/banking-app

replicas:
  auth: 1
  account: 1
  payment: 1
  gateway: 1
  ui: 1

resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi

database:
  enabled: true
  size: 10Gi

ingress:
  enabled: true
  host: banking-dev.example.com
  tls: false
```

#### Production (values-prod.yaml)
```yaml
global:
  environment: prod
  imageTag: v1.0.0
  registry: ghcr.io/your-org/banking-app

replicas:
  auth: 3
  account: 3
  payment: 3
  gateway: 2
  ui: 2

resources:
  requests:
    cpu: 500m
    memory: 1Gi
  limits:
    cpu: 2000m
    memory: 2Gi

database:
  enabled: false  # Use external managed database
  host: prod-postgres.example.com

ingress:
  enabled: true
  host: banking.example.com
  tls: true
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod

monitoring:
  enabled: true
  prometheus: true
  grafana: true
```

### 🔧 Manual Kubernetes Deployment
```bash
# Create namespace
kubectl create namespace banking

# Deploy database
kubectl apply -f k8s/base/postgres.yaml

# Deploy services
kubectl apply -f k8s/base/

# Deploy ingress
kubectl apply -f k8s/base/ingress.yaml

# Check deployment
kubectl get all -n banking
```

### 📊 Deploy Observability Stack
```bash
# Deploy complete observability stack
kubectl apply -k k8s/observability

# Check observability components
kubectl get pods -n observability
kubectl get services -n observability

# Access monitoring dashboards
kubectl port-forward -n observability svc/grafana 3000:3000
kubectl port-forward -n observability svc/prometheus 9090:9090
```

## 🌍 Cloud Platform Deployments

### ☁️ AWS EKS Deployment
```bash
# Create EKS cluster
eksctl create cluster --name banking-cluster --region us-west-2

# Configure kubectl
aws eks update-kubeconfig --region us-west-2 --name banking-cluster

# Deploy application
helm install banking-app ./helm/banking-app \
  --namespace banking \
  --create-namespace \
  --set global.cloud=aws \
  --set database.provider=rds \
  --set ingress.class=alb
```

### 🔵 Azure AKS Deployment
```bash
# Create AKS cluster
az aks create --resource-group banking-rg --name banking-cluster

# Get credentials
az aks get-credentials --resource-group banking-rg --name banking-cluster

# Deploy application
helm install banking-app ./helm/banking-app \
  --namespace banking \
  --create-namespace \
  --set global.cloud=azure \
  --set database.provider=postgresql \
  --set ingress.class=nginx
```

### 🌐 Google GKE Deployment
```bash
# Create GKE cluster
gcloud container clusters create banking-cluster --zone us-central1-a

# Get credentials
gcloud container clusters get-credentials banking-cluster --zone us-central1-a

# Deploy application
helm install banking-app ./helm/banking-app \
  --namespace banking \
  --create-namespace \
  --set global.cloud=gcp \
  --set database.provider=cloudsql \
  --set ingress.class=gce
```

## 🔄 CI/CD Deployments

### 🔧 Jenkins Deployment
```groovy
// Jenkinsfile deployment stage
stage('Deploy') {
    steps {
        script {
            def environment = params.DEPLOY_ENV
            
            sh """
                helm upgrade --install banking-${environment} ./helm/banking-app \
                  --namespace banking-${environment} \
                  --create-namespace \
                  --values values-${environment}.yaml \
                  --set global.imageTag=${BUILD_NUMBER} \
                  --wait --timeout=10m
            """
            
            // Health check
            sh """
                kubectl wait --for=condition=ready pod \
                  -l app.kubernetes.io/name=banking-app \
                  -n banking-${environment} \
                  --timeout=300s
            """
        }
    }
}
```

### 🦊 GitLab CI Deployment
```yaml
# .gitlab-ci.yml deployment job
deploy-production:
  stage: deploy
  image: alpine/helm:latest
  before_script:
    - kubectl config use-context $KUBE_CONTEXT
  script:
    - |
      helm upgrade --install banking-prod ./helm/banking-app \
        --namespace banking-prod \
        --create-namespace \
        --values values-prod.yaml \
        --set global.imageTag=$CI_COMMIT_SHA \
        --wait --timeout=15m
  environment:
    name: production
    url: https://banking.example.com
  when: manual
  only:
    - tags
```

### 🐙 GitHub Actions Deployment
```yaml
# .github/workflows/deploy.yml
- name: Deploy to Kubernetes
  uses: azure/k8s-deploy@v1
  with:
    manifests: |
      k8s/prod/
    images: |
      ghcr.io/${{ github.repository }}/auth-service:${{ github.sha }}
      ghcr.io/${{ github.repository }}/account-service:${{ github.sha }}
      ghcr.io/${{ github.repository }}/payment-service:${{ github.sha }}
      ghcr.io/${{ github.repository }}/api-gateway:${{ github.sha }}
      ghcr.io/${{ github.repository }}/banking-ui:${{ github.sha }}
```

### 🚀 ArgoCD GitOps Deployment
```bash
# Install ArgoCD
kubectl apply -k k8s/argocd

# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Applications will auto-sync based on Git commits
# Development: Auto-sync from main branch
# Production: Manual sync from version tags
```

## 🔒 Security Configurations

### 🛡️ Network Security
```yaml
# NetworkPolicy example
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: banking-network-policy
spec:
  podSelector:
    matchLabels:
      app: banking-app
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: api-gateway
    ports:
    - protocol: TCP
      port: 8080
```

### 🔐 Secret Management
```bash
# Create secrets
kubectl create secret generic banking-secrets \
  --from-literal=database-password=secure-password \
  --from-literal=jwt-secret=jwt-signing-key \
  --namespace banking

# Use in deployment
kubectl patch deployment auth-service \
  -p '{"spec":{"template":{"spec":{"containers":[{"name":"auth-service","env":[{"name":"DATABASE_PASSWORD","valueFrom":{"secretKeyRef":{"name":"banking-secrets","key":"database-password"}}}]}]}}}}' \
  -n banking
```

## 📊 Monitoring Deployment

### 🔍 Prometheus & Grafana
```bash
# Deploy observability stack
kubectl apply -k k8s/observability

# Check deployment status
kubectl get pods -n observability

# Access Grafana
kubectl port-forward svc/grafana 3000:3000 -n observability
# URL: http://localhost:3000 (admin/admin123)

# Access Prometheus
kubectl port-forward svc/prometheus 9090:9090 -n observability
# URL: http://localhost:9090
```

### 📈 Custom Dashboards
```bash
# Import banking-specific dashboards (automatically loaded)
# - Banking Business Metrics Dashboard
# - Banking Technical Metrics Dashboard

# Custom metrics endpoints
curl http://auth-service:8081/actuator/prometheus | grep banking_
curl http://account-service:8084/actuator/prometheus | grep banking_
curl http://payment-service:8083/actuator/prometheus | grep banking_
```

## 🔧 Troubleshooting

### 🐛 Common Issues

#### Pod Startup Issues
```bash
# Check pod status
kubectl get pods -n banking

# Describe problematic pod
kubectl describe pod <pod-name> -n banking

# Check logs
kubectl logs <pod-name> -n banking -f

# Check events
kubectl get events -n banking --sort-by='.lastTimestamp'
```

#### Service Connectivity Issues
```bash
# Test service connectivity
kubectl exec -it <pod-name> -n banking -- curl http://auth-service:8081/actuator/health

# Check service endpoints
kubectl get endpoints -n banking

# Test DNS resolution
kubectl exec -it <pod-name> -n banking -- nslookup auth-service
```

#### Database Connection Issues
```bash
# Check database pod
kubectl logs postgres-0 -n banking

# Test database connection
kubectl exec -it postgres-0 -n banking -- psql -U banking_user -d banking_db -c "SELECT 1;"

# Check database service
kubectl get svc postgres -n banking
```

#### Monitoring Issues
```bash
# Check observability stack
kubectl get pods -n observability

# Check Prometheus targets
kubectl port-forward -n observability svc/prometheus 9090:9090
# Visit http://localhost:9090/targets

# Check Grafana datasources
kubectl logs -n observability deployment/grafana
```

### 🔄 Rollback Procedures
```bash
# Helm rollback
helm rollback banking-app 1 -n banking

# Kubernetes rollback
kubectl rollout undo deployment/auth-service -n banking

# Check rollout status
kubectl rollout status deployment/auth-service -n banking

# ArgoCD rollback
# Use ArgoCD UI or CLI to rollback to previous Git commit
```

## 📋 Health Checks

### 🏥 Application Health
```bash
# Check all service health
for service in auth-service account-service payment-service api-gateway; do
  echo "Checking $service..."
  kubectl exec -it deployment/$service -n banking -- curl -f http://localhost:8080/actuator/health
done
```

### 🔍 Infrastructure Health
```bash
# Check cluster nodes
kubectl get nodes

# Check resource usage
kubectl top nodes
kubectl top pods -n banking

# Check persistent volumes
kubectl get pv,pvc -n banking

# Check observability stack
kubectl get pods -n observability
```

## 📚 Best Practices

### 🎯 Deployment Best Practices
- Use immutable image tags (not `latest`)
- Implement proper health checks
- Configure resource limits and requests
- Use namespace isolation
- Implement proper RBAC
- Regular security updates

### 🔒 Security Best Practices
- Use secrets for sensitive data
- Implement network policies
- Regular vulnerability scanning
- Principle of least privilege
- Enable audit logging

### 📊 Monitoring Best Practices
- Monitor all layers (infrastructure, application, business)
- Set up proper alerting with custom metrics
- Implement distributed tracing
- Regular backup testing
- Capacity planning with business metrics

---

**🚀 This deployment guide provides comprehensive instructions for deploying the Banking Application across various environments, from local development to production Kubernetes clusters with proper security, monitoring, and GitOps configurations.**

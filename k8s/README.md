# 🚀 Banking Application Kubernetes Manifests

## 📁 Directory Structure

```
k8s/
├── base/                    # Base Kubernetes manifests
│   ├── namespace.yaml       # Namespace definition
│   ├── secrets.yaml         # Database and JWT secrets
│   ├── configmap.yaml       # Database initialization scripts
│   ├── postgres.yaml        # PostgreSQL StatefulSet
│   ├── auth-service.yaml    # Auth service deployment
│   ├── account-service.yaml # Account service deployment
│   ├── payment-service.yaml # Payment service deployment
│   ├── api-gateway.yaml     # API Gateway deployment
│   ├── banking-ui.yaml      # Frontend deployment
│   ├── ingress.yaml         # Ingress configuration
│   └── kustomization.yaml   # Base kustomization
└── overlays/                # Environment-specific overlays
    ├── dev/                 # Development environment
    │   ├── kustomization.yaml
    │   ├── replica-patch.yaml
    │   └── resource-patch.yaml
    └── prod/                # Production environment
        ├── kustomization.yaml
        ├── replica-patch.yaml
        └── resource-patch.yaml
```

## 🚀 Quick Deployment

### Prerequisites
```bash
# Install kubectl and kustomize
kubectl version --client
kustomize version
```

### Deploy to Development
```bash
# Apply development configuration
kubectl apply -k k8s/overlays/dev

# Check deployment status
kubectl get pods -n banking-dev
kubectl get services -n banking-dev
kubectl get ingress -n banking-dev
```

### Deploy to Production
```bash
# Apply production configuration
kubectl apply -k k8s/overlays/prod

# Check deployment status
kubectl get pods -n banking-prod
kubectl get services -n banking-prod
```

## 🔧 Configuration Details

### 🗄️ Database (PostgreSQL)
- **StatefulSet**: Persistent storage with 10Gi volume
- **Initialization**: Automatic schema and sample data creation
- **Secrets**: Username and password stored securely
- **Health Checks**: Liveness and readiness probes

### 🔐 Backend Services
- **Auth Service**: Port 8081, JWT token management
- **Account Service**: Port 8084, account operations
- **Payment Service**: Port 8083, payment processing
- **API Gateway**: Port 8090, request routing

### 🎨 Frontend Service
- **Banking UI**: Port 80, Nginx-based static serving
- **Environment**: Configurable API gateway URL

### 🌐 Ingress Configuration
- **Host Routing**: Environment-specific hostnames
- **Path-based Routing**: Service-specific API paths
- **SSL/TLS**: Production environment with certificates

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

## 🔒 Security Features

### Secrets Management
```yaml
# Database credentials
postgres-secret:
  username: banking_user (base64)
  password: banking_pass (base64)

# JWT signing key
jwt-secret:
  secret: mySecretKeyForJWT (base64)
```

### Network Policies
- Services communicate through ClusterIP
- Database access restricted to backend services
- Frontend only accessible through ingress

## 🔍 Monitoring & Health Checks

### Health Endpoints
- **Liveness Probe**: `/actuator/health`
- **Readiness Probe**: `/actuator/health/readiness`
- **Startup Delay**: 30-60 seconds for backend services

### Monitoring Integration
```bash
# Check service health
kubectl exec -n banking-dev deployment/auth-service -- curl localhost:8081/actuator/health

# View logs
kubectl logs -n banking-dev deployment/auth-service -f

# Port forward for local access
kubectl port-forward -n banking-dev service/banking-ui 3000:80
```

## 🛠️ Customization

### Environment Variables
```yaml
# Backend services
- name: SPRING_PROFILES_ACTIVE
  value: "k8s"
- name: DATABASE_URL
  value: "jdbc:postgresql://postgres:5432/banking_db"

# Frontend service
- name: API_GATEWAY_URL
  value: "http://api-gateway:8090"
```

### Image Tags
```yaml
# Development
images:
- name: banking/auth-service
  newTag: dev-latest

# Production
images:
- name: banking/auth-service
  newTag: v1.0.0
```

## 🚀 Deployment Commands

### Using kubectl
```bash
# Deploy base configuration
kubectl apply -f k8s/base/

# Deploy with kustomize
kubectl apply -k k8s/overlays/dev
kubectl apply -k k8s/overlays/prod
```

### Using kustomize
```bash
# Generate manifests
kustomize build k8s/overlays/dev > dev-manifests.yaml
kustomize build k8s/overlays/prod > prod-manifests.yaml

# Apply generated manifests
kubectl apply -f dev-manifests.yaml
```

### Cleanup
```bash
# Delete development environment
kubectl delete -k k8s/overlays/dev

# Delete production environment
kubectl delete -k k8s/overlays/prod
```

---

**🎯 These Kubernetes manifests provide production-ready deployment configurations with environment-specific customizations using Kustomize overlays.**

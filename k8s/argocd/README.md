# 🚀 ArgoCD GitOps for Banking Application

## 🎯 Overview

ArgoCD configuration for GitOps-based deployment of the Banking Application with automated continuous delivery, multi-environment support, and RBAC security.

## 📁 Directory Structure

```
argocd/
├── namespace.yaml              # ArgoCD namespace and installation
├── repository.yaml             # Git repository configurations
├── rbac.yaml                   # Role-based access control
├── projects/
│   └── banking-project.yaml    # ArgoCD project definition
├── applications/
│   ├── banking-dev.yaml        # Development environment
│   ├── banking-prod.yaml       # Production environment
│   ├── observability.yaml     # Monitoring stack
│   └── banking-appset.yaml     # ApplicationSet for multi-env
├── install.sh                  # Installation script
└── kustomization.yaml          # Kustomize configuration
```

## 🚀 Quick Installation

```bash
# Install ArgoCD and banking applications
cd k8s/argocd
./install.sh

# Access ArgoCD UI
# https://localhost:8080
# Username: admin
# Password: (shown in install output)
```

## 🏗️ Architecture

### 🎯 GitOps Workflow
```
Git Repository → ArgoCD → Kubernetes Cluster
     ↓              ↓            ↓
   Commit        Detect       Deploy
   Changes       Changes      Changes
```

### 🔄 Application Structure
- **banking-dev**: Auto-sync from main branch
- **banking-prod**: Manual sync from version tags
- **observability**: Auto-sync monitoring stack
- **ApplicationSet**: Multi-environment management

## 📊 Applications

### 🏦 Banking Development
```yaml
# Auto-sync enabled
source: k8s/overlays/dev
targetRevision: main
destination: banking-dev namespace
syncPolicy: automated (prune + self-heal)
```

### 🏭 Banking Production
```yaml
# Manual sync only
source: k8s/overlays/prod
targetRevision: v1.0.0 (tags)
destination: banking-prod namespace
syncPolicy: manual
```

### 📊 Observability Stack
```yaml
# Auto-sync enabled
source: k8s/observability
targetRevision: main
destination: observability namespace
syncPolicy: automated (prune + self-heal)
```

### 🔄 ApplicationSet
```yaml
# Multi-environment generator
environments: [dev, staging, prod]
automated: dev only
manual: staging, prod
```

## 🔒 Security & RBAC

### 👥 Roles
- **banking-admin**: Full access to banking applications
- **banking-developer**: Sync and view banking applications
- **banking-viewer**: Read-only access to banking applications

### 🔑 Permissions
```yaml
banking-admin:
  - applications: *, banking/*, allow
  - repositories: *, *, allow
  - logs: get, banking/*, allow
  - exec: create, banking/*, allow

banking-developer:
  - applications: get|sync, banking/*, allow
  - logs: get, banking/*, allow
  - repositories: get, *, allow

banking-viewer:
  - applications: get, banking/*, allow
  - logs: get, banking/*, allow
```

## 🔧 Configuration

### 📦 Repository Setup
```yaml
# GitHub repository
url: https://github.com/your-org/banking-app.git
type: git
# Add credentials for private repos

# GitLab repository
url: https://gitlab.com/your-org/banking-app.git
type: git
# Add credentials for private repos
```

### 🎯 Project Configuration
```yaml
sourceRepos:
  - 'https://github.com/your-org/banking-app.git'
destinations:
  - namespace: banking-dev
  - namespace: banking-prod
  - namespace: observability
```

## 🚀 Deployment Workflow

### 🔄 Development Deployment
1. **Push to main branch**
2. **ArgoCD detects changes**
3. **Auto-sync to banking-dev**
4. **Health checks validate deployment**

### 🏭 Production Deployment
1. **Create version tag (v1.0.0)**
2. **Update banking-prod targetRevision**
3. **Manual sync in ArgoCD UI**
4. **Validate production deployment**

### 📊 Monitoring Deployment
1. **Push monitoring changes**
2. **ArgoCD auto-syncs observability**
3. **Monitoring stack updated**

## 🛠️ Operations

### 📋 Common Commands
```bash
# Check application status
kubectl get applications -n argocd

# Sync application manually
argocd app sync banking-dev

# Get application details
argocd app get banking-prod

# View application logs
argocd app logs banking-dev
```

### 🔍 Troubleshooting
```bash
# Check ArgoCD server status
kubectl get pods -n argocd

# View ArgoCD server logs
kubectl logs deployment/argocd-server -n argocd

# Check application sync status
kubectl describe application banking-dev -n argocd

# Force refresh application
argocd app get banking-dev --refresh
```

### 🔄 Sync Policies
```yaml
# Automated sync
syncPolicy:
  automated:
    prune: true      # Remove resources not in Git
    selfHeal: true   # Correct drift automatically
    allowEmpty: false # Prevent empty syncs

# Manual sync
syncPolicy:
  syncOptions:
    - CreateNamespace=true
    - PrunePropagationPolicy=foreground
```

## 📊 Monitoring

### 🎯 Application Health
- **Sync Status**: In-sync, Out-of-sync, Unknown
- **Health Status**: Healthy, Progressing, Degraded, Suspended
- **Operation Status**: Running, Failed, Error, Succeeded

### 📈 Metrics
- Application sync frequency
- Deployment success rate
- Time to deployment
- Drift detection and correction

## 🔧 Customization

### 🎯 Environment-Specific Configuration
```yaml
# Use different branches/tags per environment
dev: main branch (latest)
staging: release branches (release/v1.0)
prod: version tags (v1.0.0)
```

### 🔄 Sync Strategies
```yaml
# Fast sync for development
automated: true
prune: true
selfHeal: true

# Controlled sync for production
automated: false
manual approval required
```

### 📊 Resource Hooks
```yaml
# Pre-sync hooks
annotations:
  argocd.argoproj.io/hook: PreSync
  argocd.argoproj.io/hook-delete-policy: BeforeHookCreation

# Post-sync hooks
annotations:
  argocd.argoproj.io/hook: PostSync
  argocd.argoproj.io/hook-delete-policy: HookSucceeded
```

## 🚨 Disaster Recovery

### 💾 Backup Strategy
```bash
# Export ArgoCD applications
kubectl get applications -n argocd -o yaml > argocd-backup.yaml

# Export ArgoCD projects
kubectl get appprojects -n argocd -o yaml > projects-backup.yaml
```

### 🔄 Recovery Process
```bash
# Restore ArgoCD applications
kubectl apply -f argocd-backup.yaml

# Restore projects
kubectl apply -f projects-backup.yaml

# Sync all applications
argocd app sync --all
```

## 📚 Best Practices

### 🎯 GitOps Principles
- **Declarative**: All configuration in Git
- **Versioned**: Git history for all changes
- **Immutable**: No manual cluster changes
- **Auditable**: Complete change history

### 🔒 Security Best Practices
- Use RBAC for access control
- Separate projects for different teams
- Use private repositories for sensitive configs
- Regular security audits

### 📊 Operational Excellence
- Monitor application health continuously
- Set up proper alerting for sync failures
- Regular backup of ArgoCD configurations
- Document deployment procedures

---

**🚀 This ArgoCD setup provides enterprise-grade GitOps deployment for the Banking Application with automated continuous delivery, security, and operational excellence.**

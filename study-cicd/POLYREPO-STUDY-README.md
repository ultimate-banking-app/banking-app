# 📚 Polyrepo CI/CD Study Materials

## 🎯 Overview

Polyrepo approach where each microservice has its own repository and independent CI/CD pipeline. This enables team autonomy and service independence.

## 📁 Directory Structure

```
study-cicd/
├── jenkins-polyrepo/
│   ├── Jenkinsfile                    # Service-specific Jenkins pipeline
│   └── JENKINS-POLYREPO-STUDY.md      # Detailed study guide
├── gitlab-polyrepo/
│   ├── .gitlab-ci.yml                 # Service-specific GitLab pipeline
│   └── GITLAB-POLYREPO-STUDY.md       # Detailed study guide
├── github-actions-polyrepo/
│   ├── .github/workflows/ci-cd.yml    # Service-specific GitHub workflow
│   └── GITHUB-POLYREPO-STUDY.md       # Detailed study guide
└── POLYREPO-COMPARISON.md             # Platform comparison for polyrepo
```

## 🔄 Key Differences from Single Repo

| Aspect | Single Repo | Polyrepo |
|--------|-------------|----------|
| **Repository** | One repo, all services | One repo per service |
| **Pipeline** | One pipeline, all services | One pipeline per service |
| **Build Time** | 20-30 minutes | 5-10 minutes |
| **Team Independence** | Low | High |
| **Dependency Management** | Simple | Complex |
| **Release Coordination** | Automatic | Manual |

## 🚀 Polyrepo Benefits

### ✅ Advantages
- **Team Autonomy**: Each team owns their service
- **Independent Deployment**: Deploy services separately
- **Faster Builds**: Only build changed service
- **Technology Diversity**: Different stacks per service
- **Fault Isolation**: Failures don't affect other services

### ❌ Challenges
- **Dependency Management**: Complex cross-service dependencies
- **Configuration Duplication**: Similar configs across repos
- **Integration Testing**: Harder to test interactions
- **Release Coordination**: Managing multi-service releases

## 🔧 Implementation Patterns

### 🎯 Service Detection
```groovy
// Jenkins
SERVICE_NAME = "${env.JOB_NAME.split('/')[0]}"
```
```yaml
# GitLab
SERVICE_NAME: "${CI_PROJECT_NAME}"
```
```yaml
# GitHub Actions
SERVICE_NAME: ${{ github.event.repository.name }}
```

### 🔄 Dependency Triggering
- **Jenkins**: `build job: 'downstream-service'`
- **GitLab**: Pipeline triggers via API
- **GitHub Actions**: `workflow_dispatch` events

## 📊 Study Path

1. **Understand Polyrepo Concepts** - Service independence
2. **Learn Dependency Management** - Cross-service coordination
3. **Practice Pipeline Setup** - Individual service pipelines
4. **Implement Triggering** - Downstream service automation
5. **Compare Platforms** - Choose best fit for your needs

## 🎓 Learning Objectives

After studying these materials, you will understand:
- ✅ Polyrepo architecture patterns
- ✅ Service-specific pipeline design
- ✅ Cross-service dependency management
- ✅ Independent deployment strategies
- ✅ Team autonomy implementation
- ✅ Platform-specific polyrepo features

---

**🎯 These materials provide hands-on experience with polyrepo CI/CD patterns across different platforms.**

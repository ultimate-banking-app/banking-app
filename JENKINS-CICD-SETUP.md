# Jenkins CI/CD Setup for Banking Application Monorepo

## 🏗️ Architecture Overview

This Jenkins CI/CD setup provides a complete monorepo solution for the Banking Application with:

- **Shared Libraries**: Reusable pipeline components
- **Multibranch Pipeline**: Automatic branch detection and building
- **Parallel Execution**: Efficient builds with parallel stages
- **Change Detection**: Only build/deploy changed services
- **Quality Gates**: SonarQube integration with quality checks
- **Security Scanning**: OWASP dependency check, container scanning
- **Multi-Environment**: Dev, Staging, Production deployments

## 📁 Project Structure

```
banking-app/
├── Jenkinsfile                          # Main pipeline definition
├── jenkins-shared-library/              # Shared library components
│   └── vars/
│       ├── bankingUtils.groovy         # Utility functions
│       ├── bankingBuild.groovy         # Build operations
│       ├── bankingTest.groovy          # Testing operations
│       ├── bankingDocker.groovy        # Docker operations
│       ├── bankingDeploy.groovy        # Deployment operations
│       ├── bankingQuality.groovy       # Code quality checks
│       ├── bankingSecurity.groovy      # Security scanning
│       └── bankingNotification.groovy  # Notifications
├── jenkins/
│   ├── docker-compose.jenkins.yml      # Jenkins infrastructure
│   ├── jenkins-casc.yml               # Configuration as Code
│   └── multibranch-config.xml         # Pipeline configuration
└── [microservices directories...]
```

## 🚀 Quick Setup

### 1. Start Jenkins Infrastructure

```bash
# Navigate to jenkins directory
cd jenkins

# Start Jenkins with all tools
docker-compose -f docker-compose.jenkins.yml up -d

# Wait for services to start (2-3 minutes)
docker-compose -f docker-compose.jenkins.yml logs -f jenkins
```

### 2. Access Jenkins Dashboard

```bash
# Jenkins will be available at:
http://localhost:8080

# Default credentials:
Username: admin
Password: admin123
```

### 3. Verify Setup

```bash
# Check all services are running
docker-compose -f docker-compose.jenkins.yml ps

# Expected services:
# - jenkins (port 8080)
# - sonarqube (port 9000) 
# - nexus (port 8081)
# - postgres (port 5432)
# - redis (port 6379)
```

## 🔧 Pipeline Features

### Shared Library Components

#### 1. **bankingUtils** - Core Utilities
- Change detection for monorepo
- Service discovery
- Test result publishing
- Artifact archiving

#### 2. **bankingBuild** - Build Management
- Shared module building
- Parallel service builds
- Maven lifecycle management

#### 3. **bankingTest** - Testing Framework
- Unit test execution
- Integration test runs
- Health checks
- Smoke testing

#### 4. **bankingDocker** - Container Management
- Multi-service image building
- Registry push/pull
- Image cleanup

#### 5. **bankingDeploy** - Deployment Automation
- Environment-specific deployments
- Kubernetes integration
- Rollback capabilities

#### 6. **bankingQuality** - Code Quality
- SonarQube integration
- Code coverage reports
- Quality gate enforcement

#### 7. **bankingSecurity** - Security Scanning
- Dependency vulnerability checks
- Container security scanning
- SAST analysis

#### 8. **bankingNotification** - Communication
- Slack notifications
- Email alerts
- Deployment status updates

## 📋 Pipeline Stages

### 1. **Checkout**
- Source code checkout
- Git history analysis
- Branch information gathering

### 2. **Detect Changes**
- Identifies modified services
- Optimizes build process
- Supports full or incremental builds

### 3. **Build & Test (Parallel)**
- Shared module compilation
- Code quality analysis
- Parallel execution for efficiency

### 4. **Build Services**
- Service-specific builds
- Dependency management
- Artifact generation

### 5. **Run Tests (Parallel)**
- Unit test execution
- Integration test runs
- Test result aggregation

### 6. **Security Scan**
- OWASP dependency check
- Container vulnerability scanning
- Static code analysis

### 7. **Build Docker Images**
- Multi-service image creation
- Registry push operations
- Image tagging strategy

### 8. **Deploy to Environment**
- Environment-specific deployment
- Configuration management
- Service orchestration

### 9. **Health Check**
- Service availability verification
- Endpoint testing
- Deployment validation

### 10. **Smoke Tests**
- Critical path testing
- End-to-end validation
- Production readiness check

## 🎯 Demo Scenarios

### Scenario 1: Full Pipeline Run

```bash
# 1. Trigger pipeline manually
# Go to Jenkins → Banking Application → main branch → Build Now

# 2. Monitor pipeline execution
# Watch parallel stages execute
# Review test results and quality reports

# 3. Check deployment status
curl http://localhost:8080/actuator/health  # API Gateway
curl http://localhost:8081/actuator/health  # Auth Service
```

### Scenario 2: Change Detection Demo

```bash
# 1. Make changes to specific service
echo "// Updated" >> account-service/src/main/java/AccountController.java

# 2. Commit and push changes
git add account-service/
git commit -m "Update account service"
git push origin main

# 3. Pipeline will detect only account-service changed
# Only account-service will be built and deployed
```

### Scenario 3: Multi-Environment Deployment

```bash
# 1. Deploy to Development
# Pipeline parameter: DEPLOY_ENV = dev

# 2. Deploy to Staging  
# Pipeline parameter: DEPLOY_ENV = staging

# 3. Deploy to Production
# Pipeline parameter: DEPLOY_ENV = prod
# Requires manual approval
```

### Scenario 4: Quality Gate Failure

```bash
# 1. Introduce code quality issues
# Add code with high complexity or security issues

# 2. Pipeline will fail at Quality Gate
# SonarQube analysis will block deployment

# 3. Fix issues and re-run pipeline
```

## 🔍 Monitoring & Observability

### Jenkins Dashboard
- **Build History**: Track all pipeline executions
- **Test Results**: Unit and integration test reports
- **Code Coverage**: Jacoco coverage reports
- **Quality Reports**: SonarQube integration

### SonarQube Integration
```bash
# Access SonarQube dashboard
http://localhost:9000

# Default credentials:
Username: admin
Password: admin
```

### Nexus Repository
```bash
# Access Nexus repository
http://localhost:8081

# Default credentials:
Username: admin
Password: admin123
```

## 🛠️ Customization

### Adding New Services

1. **Update Shared Library**:
```groovy
// In bankingUtils.groovy
def getAllServices() {
    return [
        'api-gateway',
        'auth-service',
        // ... existing services
        'new-service'  // Add new service
    ]
}
```

2. **Create Service Dockerfile**:
```dockerfile
# new-service/Dockerfile
FROM openjdk:17-jre-slim
COPY target/new-service-*.jar app.jar
EXPOSE 8090
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

### Environment Configuration

```yaml
# jenkins-casc.yml - Add new environment
environments:
  dev:
    url: "http://dev-banking.local"
  staging:
    url: "http://staging-banking.local"
  prod:
    url: "https://banking.company.com"
  new-env:  # Add new environment
    url: "http://new-env-banking.local"
```

## 🔒 Security Best Practices

### Credential Management
- Use Jenkins Credential Store
- Rotate tokens regularly
- Implement least privilege access

### Pipeline Security
- Scan dependencies for vulnerabilities
- Container image security scanning
- Static code analysis integration

### Access Control
- Role-based access control
- Branch protection rules
- Approval workflows for production

## 📊 Performance Optimization

### Parallel Execution
- Services build in parallel
- Test execution parallelization
- Independent deployment stages

### Caching Strategy
- Maven dependency caching
- Docker layer caching
- SonarQube analysis caching

### Resource Management
- Jenkins executor optimization
- Container resource limits
- Database connection pooling

## 🚨 Troubleshooting

### Common Issues

1. **Pipeline Fails at Build Stage**
```bash
# Check Maven dependencies
mvn dependency:tree

# Verify shared module installation
ls ~/.m2/repository/com/banking/shared/
```

2. **Docker Build Failures**
```bash
# Check Docker daemon
docker info

# Verify Dockerfile syntax
docker build -t test-image .
```

3. **SonarQube Connection Issues**
```bash
# Check SonarQube status
curl http://localhost:9000/api/system/status

# Verify token configuration
# Jenkins → Manage Jenkins → Configure System → SonarQube
```

### Log Analysis
```bash
# Jenkins logs
docker-compose -f docker-compose.jenkins.yml logs jenkins

# Pipeline console output
# Available in Jenkins UI → Build → Console Output

# Service-specific logs
docker-compose logs banking-postgres
docker-compose logs banking-redis
```

## 📈 Metrics & Reporting

### Build Metrics
- Build success/failure rates
- Build duration trends
- Test execution times

### Quality Metrics
- Code coverage trends
- Technical debt tracking
- Security vulnerability counts

### Deployment Metrics
- Deployment frequency
- Lead time for changes
- Mean time to recovery

## 🎓 Best Practices

### Pipeline Design
- Keep stages focused and atomic
- Use parallel execution where possible
- Implement proper error handling

### Code Quality
- Enforce quality gates
- Maintain high test coverage
- Regular dependency updates

### Security
- Regular security scanning
- Credential rotation
- Access audit trails

---

## 🚀 Getting Started Checklist

- [ ] Start Jenkins infrastructure with Docker Compose
- [ ] Access Jenkins dashboard (localhost:8080)
- [ ] Verify SonarQube integration (localhost:9000)
- [ ] Create multibranch pipeline for banking application
- [ ] Configure GitHub webhook for automatic builds
- [ ] Run first pipeline build
- [ ] Verify all services deploy successfully
- [ ] Test change detection with service modification
- [ ] Configure Slack/email notifications
- [ ] Set up production approval workflow

**Ready to demonstrate enterprise-grade CI/CD for your banking application monorepo!** 🏦

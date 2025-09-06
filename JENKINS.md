# 🔧 Banking Application - Jenkins CI/CD Pipeline

## 🎯 Overview

This Jenkins pipeline provides enterprise-grade CI/CD automation for the Banking Application monorepo, featuring shared libraries, parallel processing, quality gates, and multi-environment deployments.

## 🏗️ Pipeline Architecture

### 📊 Pipeline Stages
1. **Checkout** - Source code retrieval and validation
2. **Change Detection** - Intelligent monorepo change detection
3. **Build & Test** - Parallel service builds and testing
4. **Code Quality** - SonarQube analysis and quality gates
5. **Security Scans** - OWASP, SAST, and container scanning
6. **Package** - Docker image building and registry push
7. **Deploy** - Environment-specific deployments

### 🔄 Shared Library Structure
```
jenkins-shared-library/
├── vars/
│   ├── bankingBuild.groovy      # Build operations
│   ├── bankingQuality.groovy    # Quality analysis
│   ├── bankingDocker.groovy     # Container operations
│   ├── bankingSecurity.groovy   # Security scanning
│   ├── bankingDeploy.groovy     # Deployment operations
│   └── bankingUtils.groovy      # Utility functions
└── src/com/banking/
    ├── BuildManager.groovy      # Build management class
    ├── QualityGate.groovy       # Quality gate management
    └── DeploymentManager.groovy # Deployment management
```

## 🚀 Key Features

### 🎯 Monorepo Optimization
- **Change Detection**: Only builds/tests changed services
- **Parallel Execution**: Independent service processing
- **Dependency Awareness**: Shared changes trigger all services
- **Build Optimization**: Maven parallel builds with caching

### 🔒 Security Integration
- **OWASP Dependency Check**: Vulnerability scanning
- **SAST Analysis**: Static application security testing
- **Container Scanning**: Docker image security analysis
- **Quality Gates**: Security-based build failures

### 📊 Quality Assurance
- **SonarQube Integration**: Code quality analysis
- **Test Coverage**: Minimum 80% coverage requirement
- **Code Quality Gates**: Automated quality checks
- **Performance Testing**: Load testing integration

### 🌍 Multi-Environment Support
- **Development**: Auto-deploy on main branch
- **Staging**: Manual deployment for release candidates
- **Production**: Approval-required deployment
- **Review Environments**: Temporary PR environments

## 📁 Pipeline Configuration

### 🔧 Jenkinsfile Structure
```groovy
@Library('banking-shared-library') _

pipeline {
    agent any
    
    environment {
        MAVEN_OPTS = '-Xmx2g -XX:+UseG1GC -Dmaven.artifact.threads=10'
        NODE_VERSION = '18'
        DOCKER_BUILDKIT = '1'
    }
    
    parameters {
        choice(name: 'DEPLOY_ENV', choices: ['dev', 'staging', 'prod'])
        booleanParam(name: 'SKIP_TESTS', defaultValue: false)
        booleanParam(name: 'DEPLOY_ALL_SERVICES', defaultValue: true)
    }
    
    stages {
        stage('Checkout') { /* ... */ }
        stage('Change Detection') { /* ... */ }
        stage('Build & Test') { /* ... */ }
        stage('Code Quality') { /* ... */ }
        stage('Security Scans') { /* ... */ }
        stage('Package') { /* ... */ }
        stage('Deploy') { /* ... */ }
    }
}
```

### 🔧 Environment Variables
```groovy
environment {
    // Maven Configuration
    MAVEN_OPTS = '-Xmx2g -XX:+UseG1GC -Dmaven.artifact.threads=10'
    MAVEN_CLI_OPTS = '--batch-mode --errors --fail-at-end --show-version'
    
    // Node.js Configuration
    NODE_VERSION = '18'
    
    // Docker Configuration
    DOCKER_BUILDKIT = '1'
    BUILDKIT_PROGRESS = 'plain'
    
    // Registry Configuration
    NEXUS_URL = 'http://nexus:8081'
    ECR_REGISTRY = '123456789012.dkr.ecr.us-east-1.amazonaws.com'
    
    // Quality Configuration
    SONAR_PROJECT_KEY = 'banking-application'
}
```

## 🔧 Shared Library Functions

### 🏗️ Build Operations (bankingBuild.groovy)
```groovy
// Build backend services
bankingBuild.buildServices(['auth-service', 'account-service'])

// Build frontend application
bankingBuild.buildUI()

// Optimized parallel build
bankingBuild.buildOptimized()

// Publish artifacts to Nexus
bankingBuild.publishArtifacts()
```

### 📊 Quality Operations (bankingQuality.groovy)
```groovy
// Run SonarQube analysis
bankingQuality.runSonarAnalysis()

// UI quality checks
bankingQuality.runUIQualityChecks()

// Check quality gates
bankingQuality.checkQualityGates()

// Generate reports
bankingQuality.generateReports()
```

### 🐳 Docker Operations (bankingDocker.groovy)
```groovy
// Build and push service images
bankingDocker.buildAndPushServices(['auth-service', 'account-service'])

// Build and push UI image
bankingDocker.buildAndPushUI()

// Scan images for vulnerabilities
bankingDocker.scanImages()

// Cleanup local images
bankingDocker.cleanupImages()
```

### 🔒 Security Operations (bankingSecurity.groovy)
```groovy
// OWASP dependency check
bankingSecurity.runOwaspScan()

// SAST analysis
bankingSecurity.runSastScan()

// NPM audit for frontend
bankingSecurity.runNpmAudit()

// Container security scanning
bankingSecurity.runContainerScan()
```

### 🚀 Deployment Operations (bankingDeploy.groovy)
```groovy
// Deploy to environment
bankingDeploy.deployToEnvironment('dev')

// Blue-green deployment
bankingDeploy.blueGreenDeploy('prod')

// Canary deployment
bankingDeploy.canaryDeploy('staging', 10)

// Rollback deployment
bankingDeploy.rollback('prod')
```

### 🛠️ Utility Functions (bankingUtils.groovy)
```groovy
// Print banner
bankingUtils.printBanner('Banking CI/CD Pipeline')

// Checkout code
bankingUtils.checkoutCode()

// Detect changes
def changes = bankingUtils.detectChanges()

// Send notifications
bankingUtils.notifySlack('SUCCESS', 'Deployment completed')
```

## 🔧 Setup Instructions

### 📋 Prerequisites
```bash
# Jenkins with required plugins
- Pipeline
- Blue Ocean
- Docker Pipeline
- SonarQube Scanner
- Nexus Artifact Uploader
- Kubernetes CLI
- Slack Notification

# Infrastructure
- Jenkins Master/Agent setup
- Docker registry access
- Kubernetes cluster access
- SonarQube server
- Nexus repository
```

### 🔧 Jenkins Configuration

#### 1. Install Required Plugins
```bash
# Core plugins
Pipeline
Blue Ocean
Docker Pipeline
Kubernetes CLI

# Quality plugins
SonarQube Scanner
Checkstyle
JUnit

# Security plugins
OWASP Dependency-Check
Anchore Container Image Scanner

# Notification plugins
Slack Notification
Email Extension
```

#### 2. Configure Global Tools
```bash
# Java
Name: JDK-17
JAVA_HOME: /usr/lib/jvm/java-17-openjdk

# Maven
Name: Maven-3.9
MAVEN_HOME: /opt/maven

# Node.js
Name: NodeJS-18
Installation: NodeJS 18.x

# Docker
Name: Docker
Installation: Docker CE
```

#### 3. Configure Credentials
```bash
# Docker Registry
ID: docker-registry-creds
Type: Username with password

# Kubernetes
ID: kube-config
Type: Secret file

# SonarQube
ID: sonar-token
Type: Secret text

# Nexus
ID: nexus-creds
Type: Username with password
```

#### 4. Configure Shared Library
```bash
# Library Configuration
Name: banking-shared-library
Default version: main
Retrieval method: Modern SCM
Source Code Management: Git
Repository URL: https://github.com/your-org/banking-shared-library
```

### 🔧 Pipeline Parameters

#### Build Parameters
```groovy
parameters {
    choice(
        name: 'DEPLOY_ENV',
        choices: ['dev', 'staging', 'prod'],
        description: 'Target deployment environment'
    )
    
    booleanParam(
        name: 'SKIP_TESTS',
        defaultValue: false,
        description: 'Skip running tests'
    )
    
    booleanParam(
        name: 'DEPLOY_ALL_SERVICES',
        defaultValue: true,
        description: 'Deploy all services or only changed ones'
    )
    
    booleanParam(
        name: 'RUN_SECURITY_SCANS',
        defaultValue: true,
        description: 'Run security scans'
    )
}
```

## 📊 Pipeline Execution

### 🔄 Typical Pipeline Flow
```
1. Checkout (30s)
   ├── Git clone
   ├── Submodule update
   └── Branch validation

2. Change Detection (15s)
   ├── File diff analysis
   ├── Service mapping
   └── Dependency resolution

3. Build & Test (5-10min)
   ├── Maven parallel build
   ├── NPM build (if UI changed)
   ├── Unit tests
   └── Integration tests

4. Code Quality (2-3min)
   ├── SonarQube analysis
   ├── Quality gate check
   └── Coverage validation

5. Security Scans (3-5min)
   ├── OWASP dependency check
   ├── SAST analysis
   ├── NPM audit
   └── Container scanning

6. Package (2-3min)
   ├── Docker image builds
   ├── Registry push
   └── Artifact archival

7. Deploy (1-2min)
   ├── Kubernetes deployment
   ├── Health checks
   └── Smoke tests
```

### 📈 Performance Metrics
- **Total Pipeline Duration**: 15-25 minutes
- **Parallel Execution**: Up to 4 concurrent jobs
- **Cache Hit Rate**: 80-90% for dependencies
- **Success Rate**: 95%+ for main branch

## 🔍 Monitoring & Observability

### 📊 Pipeline Metrics
```groovy
// Custom metrics collection
pipeline {
    post {
        always {
            script {
                // Collect build metrics
                def buildDuration = currentBuild.duration
                def testResults = currentBuild.testResultAction
                
                // Send to monitoring system
                bankingUtils.sendMetrics([
                    'build_duration': buildDuration,
                    'test_count': testResults?.totalCount,
                    'test_failures': testResults?.failCount
                ])
            }
        }
    }
}
```

### 🔔 Notifications
```groovy
// Slack notifications
bankingUtils.notifySlack('SUCCESS', 'Deployment to production completed')

// Email notifications
bankingUtils.sendEmail(
    'team@company.com',
    'Build Failed',
    'Pipeline failed at security scan stage'
)
```

## 🐛 Troubleshooting

### 🔧 Common Issues

#### Build Failures
```bash
# Check Maven dependencies
mvn dependency:tree

# Clear local repository
rm -rf ~/.m2/repository

# Check Java version
java -version
```

#### Docker Issues
```bash
# Check Docker daemon
docker info

# Clean up images
docker system prune -f

# Check registry connectivity
docker login <registry-url>
```

#### Kubernetes Deployment Issues
```bash
# Check cluster connectivity
kubectl cluster-info

# Check namespace
kubectl get ns

# Check deployment status
kubectl get deployments -n banking-dev
```

### 📋 Debug Commands
```groovy
// Pipeline debugging
pipeline {
    stages {
        stage('Debug') {
            steps {
                script {
                    // Print environment variables
                    sh 'env | sort'
                    
                    // Check workspace
                    sh 'ls -la'
                    
                    // Check tools
                    sh 'java -version'
                    sh 'mvn -version'
                    sh 'docker --version'
                }
            }
        }
    }
}
```

## 📚 Best Practices

### 🎯 Pipeline Optimization
- Use parallel stages for independent operations
- Implement proper caching strategies
- Use change detection to minimize build times
- Archive only necessary artifacts

### 🔒 Security Best Practices
- Use Jenkins credentials for sensitive data
- Implement security scanning at multiple stages
- Regular security updates for plugins
- Audit pipeline access and permissions

### 📊 Quality Assurance
- Implement quality gates with failure conditions
- Maintain high test coverage requirements
- Regular code quality reviews
- Automated dependency updates

### 🚀 Deployment Best Practices
- Use blue-green deployments for production
- Implement proper rollback procedures
- Health checks after deployments
- Environment-specific configurations

---

**🔧 This Jenkins pipeline provides enterprise-grade CI/CD automation for the Banking Application with comprehensive shared libraries, security scanning, quality gates, and flexible deployment strategies.**

# 🐙 GitHub Actions Single Repository CI/CD - Study Guide

## 🎯 Overview

This study guide covers GitHub Actions CI/CD implementation for a single repository approach. GitHub Actions uses YAML workflows with jobs, steps, and powerful marketplace integrations.

## 📚 Key Concepts

### 🏗️ GitHub Actions Architecture
- **Workflows**: Automated processes triggered by events
- **Jobs**: Groups of steps that execute on the same runner
- **Steps**: Individual tasks within a job
- **Actions**: Reusable units of code
- **Runners**: Execution environments (GitHub-hosted or self-hosted)

### 🔄 Workflow Structure
```
Trigger → Jobs (parallel/sequential) → Steps → Actions
```

## 📋 Workflow Configuration Explained

### 🎯 Workflow Triggers
```yaml
name: 🏦 Banking App CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]
  release:
    types: [published]
```
**Purpose**: Define when workflow executes
**Key Points**:
- **Push**: Triggers on branch pushes
- **Pull Request**: Triggers on PR events
- **Release**: Triggers on GitHub releases
- **Multiple Triggers**: Workflow can have multiple trigger conditions

### 🌍 Environment Variables
```yaml
env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}
  MAVEN_OPTS: -Xmx2g -XX:+UseG1GC
  NODE_VERSION: 18
```
**Purpose**: Define workflow-level variables
**Key Points**:
- Available to all jobs in workflow
- Can reference GitHub context variables
- Used for configuration consistency

### 🔨 Build Jobs

#### Backend Build Job
```yaml
build-backend:
  name: 🔨 Build Backend
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4

    - name: Set up JDK 17
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
        cache: maven

    - name: Build backend services
      run: |
        echo "🔨 Building backend services..."
        mvn clean compile -DskipTests --batch-mode
        mvn package -DskipTests --batch-mode

    - name: Upload backend artifacts
      uses: actions/upload-artifact@v4
      with:
        name: backend-jars
        path: |
          */target/*.jar
        retention-days: 1
```
**Key Features**:
- **Marketplace Actions**: Pre-built actions from GitHub Marketplace
- **Caching**: Automatic Maven dependency caching
- **Artifacts**: Upload files for use in other jobs
- **Multi-line Commands**: Shell script execution

#### Frontend Build Job
```yaml
build-frontend:
  name: 🎨 Build Frontend
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'
        cache-dependency-path: banking-ui/package-lock.json

    - name: Build frontend
      working-directory: banking-ui
      run: |
        echo "🎨 Building frontend application..."
        npm ci --prefer-offline --no-audit
        npm run build
```
**Key Features**:
- **Working Directory**: Execute commands in specific directory
- **Environment Variables**: Reference workflow-level variables
- **NPM Caching**: Automatic node_modules caching

### 🧪 Test Jobs

#### Backend Tests with Services
```yaml
test-backend:
  name: 🧪 Test Backend
  runs-on: ubuntu-latest
  needs: build-backend
  services:
    postgres:
      image: postgres:13
      env:
        POSTGRES_DB: banking_test
        POSTGRES_USER: banking_user
        POSTGRES_PASSWORD: banking_pass
      options: >-
        --health-cmd pg_isready
        --health-interval 10s
        --health-timeout 5s
        --health-retries 5
      ports:
        - 5432:5432

  steps:
    - uses: actions/checkout@v4
    - name: Set up JDK 17
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
        cache: maven

    - name: Run backend tests
      env:
        SPRING_PROFILES_ACTIVE: test
        SPRING_DATASOURCE_URL: jdbc:postgresql://localhost:5432/banking_test
        SPRING_DATASOURCE_USERNAME: banking_user
        SPRING_DATASOURCE_PASSWORD: banking_pass
      run: |
        echo "🧪 Running backend tests..."
        mvn test --batch-mode
        mvn jacoco:report
```
**Key Features**:
- **Job Dependencies**: `needs` keyword for job ordering
- **Services**: Additional containers (PostgreSQL)
- **Health Checks**: Ensure service readiness
- **Environment Variables**: Job-specific configuration

#### Frontend Tests
```yaml
test-frontend:
  name: 🧪 Test Frontend
  runs-on: ubuntu-latest
  needs: build-frontend
  steps:
    - uses: actions/checkout@v4

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'
        cache-dependency-path: banking-ui/package-lock.json

    - name: Run frontend tests
      working-directory: banking-ui
      run: |
        echo "🧪 Running frontend tests..."
        npm ci --prefer-offline --no-audit
        npm test -- --coverage --watchAll=false
```
**Key Features**:
- **Dependency Management**: Reuse cached dependencies
- **Test Coverage**: Generate coverage reports
- **Working Directory**: Frontend-specific execution context

### 📊 Quality Gate Job
```yaml
quality-gate:
  name: 📊 Quality Gate
  runs-on: ubuntu-latest
  needs: [test-backend, test-frontend]
  steps:
    - uses: actions/checkout@v4

    - name: Set up JDK 17
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
        cache: maven

    - name: SonarCloud Scan
      uses: SonarSource/sonarcloud-github-action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```
**Key Features**:
- **Multiple Dependencies**: Wait for multiple jobs
- **Third-party Actions**: SonarCloud marketplace action
- **Secrets**: Secure token management
- **Automatic Token**: GitHub provides GITHUB_TOKEN

### 🔒 Security Scanning Job
```yaml
security-scan:
  name: 🔒 Security Scan
  runs-on: ubuntu-latest
  needs: [build-backend, build-frontend]
  steps:
    - uses: actions/checkout@v4

    - name: Set up JDK 17
      uses: actions/setup-java@v4
      with:
        java-version: '17'
        distribution: 'temurin'
        cache: maven

    - name: OWASP Dependency Check
      run: |
        echo "🔒 Running OWASP dependency check..."
        mvn org.owasp:dependency-check-maven:check -DfailBuildOnCVSS=7 --batch-mode

    - name: Setup Node.js for security scan
      uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'
        cache-dependency-path: banking-ui/package-lock.json

    - name: NPM Security Audit
      working-directory: banking-ui
      run: |
        echo "🔒 Running NPM security audit..."
        npm ci --prefer-offline --no-audit
        npm audit --audit-level=moderate
```
**Key Features**:
- **Multi-language Scanning**: Java and Node.js security checks
- **Tool Setup**: Multiple language environments in one job
- **Security Thresholds**: Configurable severity levels

### 🐳 Container Build Job
```yaml
build-images:
  name: 🐳 Build Images
  runs-on: ubuntu-latest
  needs: [quality-gate, security-scan]
  if: github.ref == 'refs/heads/main' || github.event_name == 'release'
  strategy:
    matrix:
      service: [auth-service, account-service, payment-service, api-gateway, banking-ui]

  steps:
    - uses: actions/checkout@v4

    - name: Download artifacts
      uses: actions/download-artifact@v4
      with:
        name: ${{ matrix.service == 'banking-ui' && 'frontend-dist' || 'backend-jars' }}

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3

    - name: Log in to Container Registry
      uses: docker/login-action@v3
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}

    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}/${{ matrix.service }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=semver,pattern={{version}}
          type=sha

    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: ${{ matrix.service }}
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
```
**Key Features**:
- **Matrix Strategy**: Build multiple services in parallel
- **Conditional Execution**: Only run on specific conditions
- **Docker Buildx**: Advanced Docker building capabilities
- **GitHub Container Registry**: Built-in container registry
- **Cache Optimization**: GitHub Actions cache for Docker layers

### 🚀 Deployment Jobs

#### Development Deployment
```yaml
deploy-dev:
  name: 🚀 Deploy to Development
  runs-on: ubuntu-latest
  needs: build-images
  if: github.ref == 'refs/heads/main'
  environment:
    name: development
    url: https://banking-dev.example.com
  steps:
    - uses: actions/checkout@v4

    - name: Deploy to Kubernetes
      run: |
        echo "🚀 Deploying to development environment..."
        helm upgrade --install banking-dev ./helm/banking-app \
          --namespace banking-dev \
          --create-namespace \
          --set global.environment=dev \
          --set global.imageTag=${{ github.sha }} \
          --wait --timeout=10m
```
**Key Features**:
- **Environment Protection**: GitHub environment with protection rules
- **Conditional Deployment**: Only deploy from main branch
- **Environment URL**: Link to deployed application
- **Kubernetes Integration**: Helm deployment

#### Production Deployment
```yaml
deploy-prod:
  name: 🏭 Deploy to Production
  runs-on: ubuntu-latest
  needs: build-images
  if: github.event_name == 'release' && !contains(github.event.release.tag_name, 'rc')
  environment:
    name: production
    url: https://banking.example.com
  steps:
    - uses: actions/checkout@v4

    - name: Deploy to Kubernetes
      run: |
        echo "🚀 Deploying to production environment..."
        helm upgrade --install banking-prod ./helm/banking-app \
          --namespace banking-prod \
          --create-namespace \
          --set global.environment=prod \
          --set global.imageTag=${{ github.event.release.tag_name }} \
          --set replicas.auth=3 \
          --set replicas.account=3 \
          --set replicas.payment=3 \
          --wait --timeout=20m
```
**Key Features**:
- **Release-based Deployment**: Only deploy on releases
- **Tag Filtering**: Exclude release candidates
- **Production Configuration**: Higher replica counts
- **Manual Approval**: Environment protection rules

## 🔧 GitHub Actions Features

### 🎯 Advanced Capabilities
- **Matrix Builds**: Parallel execution with different parameters
- **Conditional Execution**: Complex if conditions
- **Reusable Workflows**: Share workflows across repositories
- **Composite Actions**: Create custom actions
- **Self-hosted Runners**: Custom execution environments

### 📊 Built-in Integrations
- **GitHub Container Registry**: Free container storage
- **Security Alerts**: Dependency vulnerability scanning
- **Environment Protection**: Deployment approval workflows
- **Status Checks**: PR integration and branch protection
- **Marketplace**: Thousands of pre-built actions

## 🚀 Best Practices

### ✅ Optimization Strategies
```yaml
# Efficient job dependencies
jobs:
  build:
    # ... build job
  
  test:
    needs: build  # Only run after build
    # ... test job
  
  deploy:
    needs: [build, test]  # Wait for multiple jobs
    # ... deploy job

# Conditional execution
- name: Deploy to production
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  run: echo "Deploying to production"

# Matrix optimization
strategy:
  matrix:
    node-version: [16, 18, 20]
    os: [ubuntu-latest, windows-latest]
  fail-fast: false  # Don't cancel other jobs on failure
```

### 🔒 Security Best Practices
```yaml
# Use specific action versions
- uses: actions/checkout@v4  # Not @main

# Limit permissions
permissions:
  contents: read
  packages: write
  security-events: write

# Use secrets properly
env:
  API_KEY: ${{ secrets.API_KEY }}

# Mask sensitive data
- name: Deploy
  run: |
    echo "::add-mask::${{ secrets.DEPLOY_TOKEN }}"
    echo "Deploying with token: ${{ secrets.DEPLOY_TOKEN }}"
```

## 🔍 Troubleshooting

### 🐛 Common Issues

#### Action Failures
```yaml
# Add debugging
- name: Debug environment
  run: |
    echo "Runner OS: ${{ runner.os }}"
    echo "GitHub context: ${{ toJson(github) }}"
    env | sort

# Continue on error
- name: Optional step
  run: npm run optional-task
  continue-on-error: true
```

#### Artifact Issues
```yaml
# Check artifact upload
- name: Upload artifacts
  uses: actions/upload-artifact@v4
  with:
    name: build-artifacts
    path: |
      dist/
      !dist/**/*.map  # Exclude source maps
    if-no-files-found: error  # Fail if no files found
```

#### Matrix Problems
```yaml
# Handle matrix failures
strategy:
  matrix:
    service: [auth, account, payment]
  fail-fast: false  # Continue other matrix jobs

# Exclude specific combinations
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest]
    node: [16, 18]
    exclude:
      - os: windows-latest
        node: 16
```

## 📊 Performance Optimization

### ⚡ Speed Improvements
- **Parallel Jobs**: Use matrix and needs strategically
- **Caching**: Cache dependencies and build outputs
- **Artifact Management**: Only upload necessary files
- **Runner Selection**: Choose appropriate runner types

### 📈 Resource Management
```yaml
# Timeout configuration
jobs:
  build:
    timeout-minutes: 30  # Prevent hanging jobs
    
# Resource-intensive jobs
runs-on: ubuntu-latest-4-cores  # Use larger runners when needed
```

## 🎓 Study Questions

### 📝 Basic Questions
1. What is the difference between jobs and steps in GitHub Actions?
2. How do you pass data between jobs?
3. What are the different types of runners available?
4. How do you implement conditional job execution?

### 🧠 Advanced Questions
1. How would you create a reusable workflow?
2. What strategies exist for handling secrets securely?
3. How can you optimize workflow execution time?
4. What is the difference between `needs` and `if` conditions?

### 💡 Practical Exercises
1. Create a matrix build for multiple Node.js versions
2. Implement a workflow that deploys to multiple environments
3. Create a custom composite action
4. Add a job that runs only on specific file changes
5. Implement a workflow that triggers another repository's workflow

## 📚 Additional Resources

### 🔗 GitHub Documentation
- [GitHub Actions](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Marketplace](https://github.com/marketplace?type=actions)

### 🛠️ Integration Guides
- [Docker Integration](https://docs.github.com/en/actions/publishing-packages/publishing-docker-images)
- [Security Hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [Self-hosted Runners](https://docs.github.com/en/actions/hosting-your-own-runners)

---

**🐙 This study guide provides comprehensive understanding of GitHub Actions single repository implementation with practical examples and advanced features for modern CI/CD practices.**

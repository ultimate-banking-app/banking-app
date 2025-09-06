# 🦊 GitLab Single Repository CI/CD - Study Guide

## 🎯 Overview

This study guide covers GitLab CI/CD pipeline implementation for a single repository approach. GitLab CI/CD uses YAML configuration with stages, jobs, and powerful built-in features.

## 📚 Key Concepts

### 🏗️ GitLab CI/CD Architecture
- **Stages**: Sequential execution phases
- **Jobs**: Individual tasks within stages
- **Runners**: Execution environments
- **Artifacts**: Files passed between jobs
- **Cache**: Dependency optimization

### 🔄 Pipeline Flow
```
build → test → quality → security → package → deploy
```

## 📋 Pipeline Configuration Explained

### 🌍 Global Configuration
```yaml
stages:
  - build
  - test
  - quality
  - security
  - package
  - deploy

variables:
  MAVEN_OPTS: "-Xmx2g -XX:+UseG1GC"
  MAVEN_CLI_OPTS: "--batch-mode --errors --fail-at-end --show-version"
  DOCKER_DRIVER: overlay2
  NODE_VERSION: "18"
```
**Purpose**: Define pipeline structure and global variables
**Key Points**:
- Stages define execution order
- Variables available to all jobs
- Docker driver for container builds

### 🔨 Build Stage Jobs

#### Backend Build
```yaml
build-backend:
  stage: build
  image: maven:3.9-openjdk-17
  cache:
    key: maven-cache
    paths:
      - .m2/repository/
  before_script:
    - export MAVEN_USER_HOME=`pwd`/.m2
  script:
    - echo "🔨 Building backend services..."
    - mvn $MAVEN_CLI_OPTS clean compile -DskipTests
    - mvn $MAVEN_CLI_OPTS package -DskipTests
  artifacts:
    paths:
      - "*/target/*.jar"
    expire_in: 1 hour
```
**Key Features**:
- **Image**: Specifies Docker image for job execution
- **Cache**: Speeds up builds by caching Maven dependencies
- **Before Script**: Setup commands before main script
- **Artifacts**: Files to pass to subsequent jobs

#### Frontend Build
```yaml
build-frontend:
  stage: build
  image: node:18-alpine
  cache:
    key: npm-cache
    paths:
      - banking-ui/node_modules/
  script:
    - echo "🎨 Building frontend application..."
    - cd banking-ui
    - npm ci --prefer-offline --no-audit
    - npm run build
  artifacts:
    paths:
      - banking-ui/dist/
    expire_in: 1 hour
```
**Key Features**:
- **Alpine Image**: Smaller, faster container
- **NPM Cache**: Caches node_modules for speed
- **Artifacts**: Frontend build output

### 🧪 Test Stage Jobs

#### Backend Tests
```yaml
test-backend:
  stage: test
  image: maven:3.9-openjdk-17
  services:
    - postgres:13
  variables:
    POSTGRES_DB: banking_test
    POSTGRES_USER: banking_user
    POSTGRES_PASSWORD: banking_pass
  cache:
    key: maven-cache
    paths:
      - .m2/repository/
    policy: pull
  script:
    - echo "🧪 Running backend tests..."
    - mvn $MAVEN_CLI_OPTS test
    - mvn jacoco:report
  artifacts:
    reports:
      junit:
        - "*/target/surefire-reports/TEST-*.xml"
      coverage_report:
        coverage_format: jacoco
        path: "*/target/site/jacoco/jacoco.xml"
```
**Key Features**:
- **Services**: Additional containers (PostgreSQL database)
- **Cache Policy**: Only pull cache, don't update
- **Reports**: GitLab-native test and coverage reporting
- **JUnit Integration**: Test results in GitLab UI

#### Frontend Tests
```yaml
test-frontend:
  stage: test
  image: node:18-alpine
  cache:
    key: npm-cache
    paths:
      - banking-ui/node_modules/
    policy: pull
  script:
    - echo "🧪 Running frontend tests..."
    - cd banking-ui
    - npm test -- --coverage --watchAll=false
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: banking-ui/coverage/cobertura-coverage.xml
```
**Key Features**:
- **Coverage Reports**: Cobertura format for GitLab
- **Cache Pull**: Reuse cached dependencies
- **Test Artifacts**: Coverage data for GitLab UI

### 📊 Quality Stage
```yaml
sonarqube-check:
  stage: quality
  image: maven:3.9-openjdk-17
  script:
    - echo "📊 Running SonarQube analysis..."
    - mvn $MAVEN_CLI_OPTS sonar:sonar
        -Dsonar.projectKey=banking-single-repo
        -Dsonar.host.url=$SONAR_HOST_URL
        -Dsonar.login=$SONAR_TOKEN
  only:
    variables:
      - $SONAR_HOST_URL
      - $SONAR_TOKEN
```
**Key Features**:
- **Conditional Execution**: Only runs if variables exist
- **SonarQube Integration**: Code quality analysis
- **Environment Variables**: Secure token handling

### 🔒 Security Stage

#### Backend Security
```yaml
security-backend:
  stage: security
  image: maven:3.9-openjdk-17
  script:
    - echo "🔒 Running backend security scans..."
    - mvn $MAVEN_CLI_OPTS org.owasp:dependency-check-maven:check -DfailBuildOnCVSS=7
  artifacts:
    reports:
      dependency_scanning:
        - "target/dependency-check-report.json"
  allow_failure: true
```
**Key Features**:
- **OWASP Integration**: Dependency vulnerability scanning
- **Security Reports**: GitLab Security Dashboard integration
- **Allow Failure**: Don't block pipeline on security issues

#### Frontend Security
```yaml
security-frontend:
  stage: security
  image: node:18-alpine
  script:
    - echo "🔒 Running frontend security scans..."
    - cd banking-ui
    - npm audit --audit-level=moderate --json > npm-audit.json || true
  artifacts:
    reports:
      dependency_scanning:
        - banking-ui/npm-audit.json
  allow_failure: true
```
**Key Features**:
- **NPM Audit**: Node.js dependency scanning
- **JSON Output**: Structured security report
- **Error Handling**: Continue on audit failures

### 🐳 Package Stage
```yaml
package-services:
  stage: package
  image: docker:24-dind
  services:
    - docker:24-dind
  variables:
    DOCKER_TLS_CERTDIR: "/certs"
  before_script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    - echo "🐳 Building and pushing Docker images..."
    - |
      for service in auth-service account-service payment-service api-gateway; do
        echo "Building $service..."
        cd $service
        docker build -t $CI_REGISTRY_IMAGE/$service:$CI_COMMIT_SHA .
        docker tag $CI_REGISTRY_IMAGE/$service:$CI_COMMIT_SHA $CI_REGISTRY_IMAGE/$service:latest
        docker push $CI_REGISTRY_IMAGE/$service:$CI_COMMIT_SHA
        docker push $CI_REGISTRY_IMAGE/$service:latest
        cd ..
      done
  only:
    - main
    - develop
```
**Key Features**:
- **Docker-in-Docker**: Build containers within containers
- **Registry Integration**: GitLab Container Registry
- **Multi-line Scripts**: Complex shell operations
- **Branch Restrictions**: Only build on specific branches

### 🚀 Deploy Stages

#### Development Deployment
```yaml
deploy-dev:
  stage: deploy
  image: alpine/helm:latest
  before_script:
    - apk add --no-cache kubectl
    - echo $KUBE_CONFIG | base64 -d > ~/.kube/config
  script:
    - echo "🚀 Deploying to development..."
    - |
      helm upgrade --install banking-dev ./helm/banking-app \
        --namespace banking-dev \
        --create-namespace \
        --set global.environment=dev \
        --set global.imageTag=$CI_COMMIT_SHA \
        --wait --timeout=10m
  environment:
    name: development
    url: https://banking-dev.example.com
  only:
    - main
```
**Key Features**:
- **Helm Deployment**: Kubernetes package manager
- **Environment Tracking**: GitLab environment monitoring
- **Automatic Deployment**: Triggers on main branch
- **Health Checks**: Wait for deployment completion

#### Manual Deployments
```yaml
deploy-staging:
  stage: deploy
  # ... configuration ...
  when: manual
  only:
    - main

deploy-prod:
  stage: deploy
  # ... configuration ...
  when: manual
  only:
    - tags
```
**Key Features**:
- **Manual Triggers**: Require human approval
- **Tag-based**: Production only from tags
- **Environment Protection**: Manual gates for critical environments

## 🔧 GitLab CI/CD Features

### 📊 Built-in Integrations
- **Test Reports**: JUnit, coverage visualization
- **Security Dashboard**: Vulnerability tracking
- **Container Registry**: Built-in Docker registry
- **Environment Tracking**: Deployment monitoring
- **Merge Request Pipelines**: PR-specific builds

### 🎯 Advanced Features
- **Parallel Jobs**: Automatic parallelization
- **Dynamic Pipelines**: Conditional job execution
- **Multi-project Pipelines**: Cross-repository triggers
- **Review Apps**: Temporary environments
- **Auto DevOps**: Automated CI/CD setup

## 🚀 Best Practices

### ✅ Optimization Strategies
```yaml
# Efficient caching
cache:
  key: "$CI_COMMIT_REF_SLUG"
  paths:
    - .m2/repository/
    - node_modules/
  policy: pull-push

# Conditional execution
rules:
  - if: '$CI_COMMIT_BRANCH == "main"'
  - if: '$CI_MERGE_REQUEST_ID'
  - changes:
    - "src/**/*"
```

### 🔒 Security Best Practices
```yaml
# Use protected variables
variables:
  DEPLOY_KEY: $PROTECTED_DEPLOY_KEY

# Mask sensitive outputs
script:
  - echo "Deploying with key: ${DEPLOY_KEY:0:4}****"

# Limit job execution
only:
  refs:
    - main
    - merge_requests
  variables:
    - $CI_COMMIT_MESSAGE !~ /skip-ci/
```

## 🔍 Troubleshooting

### 🐛 Common Issues

#### Cache Problems
```yaml
# Clear cache
cache:
  key: "$CI_COMMIT_REF_SLUG-v2"  # Change version
  policy: push  # Force cache update
```

#### Docker Issues
```bash
# Check Docker daemon
docker info

# Debug build context
docker build --progress=plain --no-cache .

# Registry connectivity
docker login $CI_REGISTRY
```

#### Pipeline Failures
```yaml
# Add debugging
script:
  - set -x  # Enable debug mode
  - env | sort  # Show environment
  - pwd && ls -la  # Show workspace
```

## 📊 Performance Optimization

### ⚡ Speed Improvements
- **Parallel Jobs**: Use `needs` keyword for dependencies
- **Efficient Images**: Use Alpine variants
- **Smart Caching**: Cache dependencies and build outputs
- **Artifact Management**: Only pass necessary files

### 📈 Resource Management
```yaml
# Resource limits
variables:
  KUBERNETES_CPU_REQUEST: "100m"
  KUBERNETES_CPU_LIMIT: "500m"
  KUBERNETES_MEMORY_REQUEST: "128Mi"
  KUBERNETES_MEMORY_LIMIT: "512Mi"
```

## 🎓 Study Questions

### 📝 Basic Questions
1. What is the difference between `script` and `before_script`?
2. How do artifacts differ from cache in GitLab CI?
3. What is the purpose of the `services` keyword?
4. How do you implement conditional job execution?

### 🧠 Advanced Questions
1. How would you implement cross-project pipeline triggers?
2. What strategies exist for handling secrets in GitLab CI?
3. How can you optimize pipeline execution time?
4. What is the difference between `only` and `rules`?

### 💡 Practical Exercises
1. Add a job that runs only on merge requests
2. Implement a multi-stage Docker build
3. Create a job that deploys to multiple environments
4. Add a job that runs integration tests with external services
5. Implement a pipeline that triggers another project's pipeline

## 📚 Additional Resources

### 🔗 GitLab Documentation
- [GitLab CI/CD](https://docs.gitlab.com/ee/ci/)
- [Pipeline Configuration](https://docs.gitlab.com/ee/ci/yaml/)
- [Docker Integration](https://docs.gitlab.com/ee/ci/docker/)

### 🛠️ Integration Guides
- [Kubernetes Deployment](https://docs.gitlab.com/ee/ci/environments/kubernetes.md)
- [Security Scanning](https://docs.gitlab.com/ee/user/application_security/)
- [Container Registry](https://docs.gitlab.com/ee/user/packages/container_registry/)

---

**🦊 This study guide provides comprehensive understanding of GitLab CI/CD single repository implementation with practical examples and advanced features for modern DevOps practices.**

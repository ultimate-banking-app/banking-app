# 🔧 Jenkins Single Repository CI/CD - Study Guide

## 🎯 Overview

This study guide covers Jenkins CI/CD pipeline implementation for a single repository containing multiple microservices. Unlike monorepo strategies, this approach treats the entire repository as one unit.

## 📚 Key Concepts

### 🏗️ Single Repository Pipeline
- **One Pipeline**: Single Jenkinsfile for entire repository
- **Sequential Processing**: All services built together
- **Unified Deployment**: All services deployed as a unit
- **Shared Configuration**: Common settings across all services

### 🔄 Pipeline Structure
```
Checkout → Build Backend → Build Frontend → Test → Quality → Security → Package → Deploy
```

## 📋 Pipeline Stages Explained

### 1. **Checkout Stage**
```groovy
stage('Checkout') {
    steps {
        echo '📥 Checking out source code...'
        checkout scm
        sh 'git log --oneline -5'
    }
}
```
**Purpose**: Retrieve source code and show recent commits
**Key Points**:
- Uses `checkout scm` for automatic SCM detection
- Shows git history for debugging
- Sets up workspace for subsequent stages

### 2. **Build Backend Stage**
```groovy
stage('Build Backend') {
    steps {
        echo '🔨 Building backend services...'
        sh '''
            mvn clean compile -DskipTests
            mvn package -DskipTests
        '''
    }
    post {
        always {
            archiveArtifacts artifacts: '*/target/*.jar', allowEmptyArchive: true
        }
    }
}
```
**Purpose**: Compile and package all Java services
**Key Points**:
- Builds all services simultaneously
- Archives JAR files for later use
- Skips tests in build stage for speed

### 3. **Build Frontend Stage**
```groovy
stage('Build Frontend') {
    steps {
        echo '🎨 Building frontend application...'
        dir('banking-ui') {
            sh '''
                npm ci
                npm run build
            '''
        }
    }
}
```
**Purpose**: Build Vue.js frontend application
**Key Points**:
- Uses `npm ci` for reproducible builds
- Changes directory to frontend folder
- Archives build artifacts

### 4. **Test Stage (Parallel)**
```groovy
stage('Test') {
    parallel {
        stage('Backend Tests') {
            when {
                not { params.SKIP_TESTS }
            }
            steps {
                echo '🧪 Running backend tests...'
                sh 'mvn test'
            }
        }
        stage('Frontend Tests') {
            steps {
                dir('banking-ui') {
                    sh 'npm test -- --coverage --watchAll=false'
                }
            }
        }
    }
}
```
**Purpose**: Run tests for both backend and frontend
**Key Points**:
- Parallel execution for speed
- Conditional execution with parameters
- Publishes test results and coverage

### 5. **Code Quality Stage**
```groovy
stage('Code Quality') {
    steps {
        withSonarQubeEnv('SonarQube') {
            sh '''
                mvn sonar:sonar \
                    -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                    -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
            '''
        }
    }
}
```
**Purpose**: Analyze code quality with SonarQube
**Key Points**:
- Uses SonarQube environment configuration
- Includes test coverage data
- Single analysis for entire repository

### 6. **Quality Gate Stage**
```groovy
stage('Quality Gate') {
    steps {
        timeout(time: 5, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: true
        }
    }
}
```
**Purpose**: Wait for SonarQube quality gate results
**Key Points**:
- Blocks pipeline if quality gate fails
- Has timeout to prevent hanging
- Aborts pipeline on failure

### 7. **Security Scan Stage**
```groovy
stage('Security Scan') {
    steps {
        sh '''
            mvn org.owasp:dependency-check-maven:check -DfailBuildOnCVSS=7
        '''
        dir('banking-ui') {
            sh 'npm audit --audit-level=moderate'
        }
    }
}
```
**Purpose**: Security vulnerability scanning
**Key Points**:
- OWASP dependency check for Java
- NPM audit for Node.js dependencies
- Configurable severity thresholds

### 8. **Build Images Stage**
```groovy
stage('Build Images') {
    when {
        anyOf {
            branch 'main'
            branch 'develop'
        }
    }
    steps {
        script {
            def services = ['auth-service', 'account-service', 'payment-service', 'api-gateway']
            
            services.each { service ->
                dir(service) {
                    def image = docker.build("${DOCKER_REGISTRY}/${service}:${BUILD_NUMBER}")
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker-registry-creds') {
                        image.push()
                        image.push('latest')
                    }
                }
            }
        }
    }
}
```
**Purpose**: Build and push Docker images
**Key Points**:
- Only runs on specific branches
- Builds all service images
- Tags with build number and latest
- Uses Jenkins Docker plugin

### 9. **Deploy Stage**
```groovy
stage('Deploy') {
    when {
        anyOf {
            branch 'main'
            branch 'develop'
        }
    }
    steps {
        script {
            def namespace = "banking-${params.ENVIRONMENT}"
            
            sh """
                helm upgrade --install banking-${params.ENVIRONMENT} ./helm/banking-app \\
                    --namespace ${namespace} \\
                    --create-namespace \\
                    --set global.environment=${params.ENVIRONMENT} \\
                    --set global.imageTag=${BUILD_NUMBER} \\
                    --wait --timeout=10m
            """
        }
    }
}
```
**Purpose**: Deploy to Kubernetes using Helm
**Key Points**:
- Uses Helm for deployment
- Creates namespace if needed
- Waits for deployment completion
- Uses build number for image tags

## 🔧 Configuration Elements

### 🛠️ Tools Configuration
```groovy
tools {
    maven 'Maven-3.9'
    nodejs 'NodeJS-18'
    jdk 'JDK-17'
}
```
**Purpose**: Define tool versions
**Requirements**: Tools must be configured in Jenkins Global Tool Configuration

### 🌍 Environment Variables
```groovy
environment {
    MAVEN_OPTS = '-Xmx2g -XX:+UseG1GC'
    DOCKER_REGISTRY = 'your-registry.com'
    SONAR_PROJECT_KEY = 'banking-single-repo'
}
```
**Purpose**: Set pipeline-wide variables
**Usage**: Available in all pipeline stages

### 📋 Parameters
```groovy
parameters {
    choice(
        name: 'ENVIRONMENT',
        choices: ['dev', 'staging', 'prod'],
        description: 'Target environment'
    )
    booleanParam(
        name: 'SKIP_TESTS',
        defaultValue: false,
        description: 'Skip running tests'
    )
}
```
**Purpose**: Allow runtime configuration
**Access**: Use `params.PARAMETER_NAME` in pipeline

## 🚀 Best Practices

### ✅ Do's
- **Use Parallel Stages**: Speed up pipeline execution
- **Archive Artifacts**: Save important build outputs
- **Implement Quality Gates**: Ensure code quality
- **Use Conditional Execution**: Skip unnecessary steps
- **Clean Workspace**: Prevent build contamination

### ❌ Don'ts
- **Don't Hardcode Values**: Use parameters and environment variables
- **Don't Skip Security Scans**: Always include security checks
- **Don't Ignore Test Failures**: Address failing tests immediately
- **Don't Deploy Without Quality Gates**: Ensure quality before deployment

## 🔍 Troubleshooting

### 🐛 Common Issues

#### Build Failures
```bash
# Check Maven dependencies
mvn dependency:tree

# Verify Java version
java -version

# Check workspace permissions
ls -la workspace/
```

#### Docker Issues
```bash
# Check Docker daemon
docker info

# Verify registry access
docker login your-registry.com

# Check image build context
docker build --no-cache .
```

#### Deployment Issues
```bash
# Check Kubernetes connectivity
kubectl cluster-info

# Verify Helm charts
helm template ./helm/banking-app

# Check namespace resources
kubectl get all -n banking-dev
```

## 📊 Pipeline Metrics

### ⏱️ Typical Execution Times
- **Checkout**: 30 seconds
- **Build Backend**: 3-5 minutes
- **Build Frontend**: 2-3 minutes
- **Tests**: 5-8 minutes (parallel)
- **Quality Analysis**: 2-3 minutes
- **Security Scans**: 3-5 minutes
- **Docker Builds**: 5-10 minutes
- **Deployment**: 2-3 minutes

**Total Pipeline Time**: 20-35 minutes

### 📈 Optimization Tips
- Use Maven dependency caching
- Implement Docker layer caching
- Run tests in parallel
- Use incremental builds when possible
- Optimize Docker image sizes

## 🎓 Study Questions

### 📝 Basic Questions
1. What is the difference between single repo and monorepo CI/CD?
2. How do you implement parallel stages in Jenkins?
3. What is the purpose of quality gates?
4. How do you handle secrets in Jenkins pipelines?

### 🧠 Advanced Questions
1. How would you implement blue-green deployment in this pipeline?
2. What strategies would you use for rollback scenarios?
3. How can you optimize build times for large repositories?
4. What monitoring would you add to this pipeline?

### 💡 Practical Exercises
1. Add a stage for database migrations
2. Implement canary deployment strategy
3. Add integration tests with external services
4. Create a rollback mechanism
5. Add performance testing stage

## 📚 Additional Resources

### 🔗 Jenkins Documentation
- [Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Docker Pipeline Plugin](https://plugins.jenkins.io/docker-workflow/)
- [SonarQube Scanner](https://plugins.jenkins.io/sonar/)

### 🛠️ Tools Integration
- [Maven Integration](https://www.jenkins.io/doc/book/pipeline/getting-started/#maven)
- [Node.js Integration](https://plugins.jenkins.io/nodejs/)
- [Kubernetes Deployment](https://plugins.jenkins.io/kubernetes-cli/)

---

**🎯 This study guide provides comprehensive understanding of Jenkins single repository CI/CD implementation with practical examples and best practices for enterprise environments.**

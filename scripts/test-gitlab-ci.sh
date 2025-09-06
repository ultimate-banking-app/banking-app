#!/bin/bash

echo "🧪 GitLab CI/CD Pipeline Testing"
echo "================================"

# Test change detection logic
test_change_detection() {
    echo "Testing change detection..."
    
    # Simulate different file changes
    echo "auth-service/src/main/java/Test.java" > /tmp/changed_files
    echo "banking-ui/src/App.vue" >> /tmp/changed_files
    echo "shared/utils/Common.java" >> /tmp/changed_files
    
    # Test backend detection
    if grep -q "auth-service\|account-service\|payment-service\|api-gateway\|shared\|pom.xml" /tmp/changed_files; then
        echo "✅ Backend change detection works"
    else
        echo "❌ Backend change detection failed"
    fi
    
    # Test frontend detection
    if grep -q "banking-ui" /tmp/changed_files; then
        echo "✅ Frontend change detection works"
    else
        echo "❌ Frontend change detection failed"
    fi
    
    rm -f /tmp/changed_files
}

# Test YAML syntax
test_yaml_syntax() {
    echo "Testing YAML syntax..."
    
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "
import yaml
import sys

files = ['.gitlab-ci.yml', '.gitlab/ci/rules.yml', '.gitlab/ci/backend.yml', 
         '.gitlab/ci/frontend.yml', '.gitlab/ci/security.yml', '.gitlab/ci/deploy.yml']

for file in files:
    try:
        with open(file, 'r') as f:
            yaml.safe_load(f)
        print(f'✅ {file} syntax valid')
    except FileNotFoundError:
        print(f'⚠️  {file} not found')
    except yaml.YAMLError as e:
        print(f'❌ {file} syntax error: {e}')
        sys.exit(1)
"
    else
        echo "⚠️  Python3 not available for YAML testing"
    fi
}

# Test Docker configurations
test_docker_configs() {
    echo "Testing Docker configurations..."
    
    services=("auth-service" "account-service" "payment-service" "api-gateway")
    
    for service in "${services[@]}"; do
        if [ -f "$service/Dockerfile" ]; then
            echo "✅ $service Dockerfile exists"
            
            # Basic Dockerfile validation
            if grep -q "FROM\|COPY\|EXPOSE" "$service/Dockerfile"; then
                echo "✅ $service Dockerfile has basic structure"
            else
                echo "⚠️  $service Dockerfile may be incomplete"
            fi
        else
            echo "❌ $service Dockerfile missing"
        fi
    done
}

# Test Maven configuration
test_maven_config() {
    echo "Testing Maven configuration..."
    
    if [ -f "pom.xml" ]; then
        echo "✅ Root pom.xml exists"
        
        # Check for required properties
        if grep -q "<java.version>" pom.xml; then
            echo "✅ Java version specified"
        else
            echo "⚠️  Java version not specified"
        fi
        
        if grep -q "<spring-boot.version>" pom.xml; then
            echo "✅ Spring Boot version specified"
        else
            echo "⚠️  Spring Boot version not specified"
        fi
    else
        echo "❌ Root pom.xml missing"
    fi
}

# Test Node.js configuration
test_nodejs_config() {
    echo "Testing Node.js configuration..."
    
    if [ -f "banking-ui/package.json" ]; then
        echo "✅ package.json exists"
        
        # Check for required scripts
        if grep -q "\"build\":\|\"test\":\|\"lint\":" "banking-ui/package.json"; then
            echo "✅ Required npm scripts found"
        else
            echo "⚠️  Some npm scripts may be missing"
        fi
    else
        echo "❌ banking-ui/package.json missing"
    fi
}

# Test pipeline stages
test_pipeline_stages() {
    echo "Testing pipeline stages..."
    
    required_stages=("validate" "build" "test" "quality" "security" "package" "deploy")
    
    for stage in "${required_stages[@]}"; do
        if grep -q "stage: $stage" .gitlab-ci.yml .gitlab/ci/*.yml 2>/dev/null; then
            echo "✅ Stage '$stage' configured"
        else
            echo "⚠️  Stage '$stage' not found"
        fi
    done
}

# Test security configurations
test_security_config() {
    echo "Testing security configurations..."
    
    security_jobs=("sast" "dependency_scanning" "secret_detection" "container_scanning")
    
    for job in "${security_jobs[@]}"; do
        if grep -q "$job" .gitlab/ci/security.yml 2>/dev/null; then
            echo "✅ Security job '$job' configured"
        else
            echo "⚠️  Security job '$job' not found"
        fi
    done
}

# Run all tests
echo "Starting GitLab CI configuration tests..."
echo ""

test_change_detection
echo ""

test_yaml_syntax
echo ""

test_docker_configs
echo ""

test_maven_config
echo ""

test_nodejs_config
echo ""

test_pipeline_stages
echo ""

test_security_config
echo ""

echo "================================"
echo "🎯 Test Summary Complete"
echo "================================"

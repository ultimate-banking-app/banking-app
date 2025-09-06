#!/bin/bash

echo "🔍 GitLab CI/CD Configuration Validation"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        ((ERRORS++))
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNINGS++))
}

echo "1. Checking file structure..."

# Check main GitLab CI file
if [ -f ".gitlab-ci.yml" ]; then
    print_status 0 "Main .gitlab-ci.yml exists"
else
    print_status 1 "Main .gitlab-ci.yml missing"
fi

# Check GitLab directory structure
if [ -d ".gitlab/ci" ]; then
    print_status 0 "GitLab CI directory exists"
else
    print_status 1 "GitLab CI directory missing"
fi

# Check individual CI files
CI_FILES=("rules.yml" "backend.yml" "frontend.yml" "security.yml" "deploy.yml" "variables.yml")
for file in "${CI_FILES[@]}"; do
    if [ -f ".gitlab/ci/$file" ]; then
        print_status 0 "CI file $file exists"
    else
        print_status 1 "CI file $file missing"
    fi
done

echo ""
echo "2. Validating YAML syntax..."

# Validate main GitLab CI YAML
if command -v yamllint >/dev/null 2>&1; then
    yamllint .gitlab-ci.yml >/dev/null 2>&1
    print_status $? "Main .gitlab-ci.yml syntax"
    
    for file in "${CI_FILES[@]}"; do
        if [ -f ".gitlab/ci/$file" ]; then
            yamllint ".gitlab/ci/$file" >/dev/null 2>&1
            print_status $? "CI file $file syntax"
        fi
    done
else
    print_warning "yamllint not installed - install with: pip install yamllint"
fi

echo ""
echo "3. Checking GitLab CI lint (requires GitLab CLI)..."

if command -v glab >/dev/null 2>&1; then
    glab ci lint >/dev/null 2>&1
    print_status $? "GitLab CI lint validation"
else
    print_warning "GitLab CLI not installed - install from: https://gitlab.com/gitlab-org/cli"
fi

echo ""
echo "4. Validating Docker configurations..."

# Check Dockerfiles exist for services
SERVICES=("auth-service" "account-service" "payment-service" "api-gateway")
for service in "${SERVICES[@]}"; do
    if [ -f "$service/Dockerfile" ]; then
        print_status 0 "Dockerfile exists for $service"
    else
        print_status 1 "Dockerfile missing for $service"
    fi
done

echo ""
echo "5. Checking required directories..."

REQUIRED_DIRS=("banking-ui" "helm" "scripts")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        print_status 0 "Directory $dir exists"
    else
        print_warning "Directory $dir missing (may be needed for deployment)"
    fi
done

echo ""
echo "6. Validating Maven configuration..."

if [ -f "pom.xml" ]; then
    print_status 0 "Root pom.xml exists"
    
    # Check if Maven can parse the POM
    if command -v mvn >/dev/null 2>&1; then
        mvn help:effective-pom -q >/dev/null 2>&1
        print_status $? "Maven POM validation"
    else
        print_warning "Maven not installed - cannot validate POM files"
    fi
else
    print_status 1 "Root pom.xml missing"
fi

echo ""
echo "7. Checking Node.js configuration..."

if [ -f "banking-ui/package.json" ]; then
    print_status 0 "package.json exists"
    
    # Check if package.json is valid JSON
    if command -v node >/dev/null 2>&1; then
        node -e "JSON.parse(require('fs').readFileSync('banking-ui/package.json', 'utf8'))" 2>/dev/null
        print_status $? "package.json syntax"
    else
        print_warning "Node.js not installed - cannot validate package.json"
    fi
else
    print_status 1 "banking-ui/package.json missing"
fi

echo ""
echo "8. Validating template files..."

TEMPLATES=(".gitlab/merge_request_templates/Default.md" ".gitlab/issue_templates/Bug.md")
for template in "${TEMPLATES[@]}"; do
    if [ -f "$template" ]; then
        print_status 0 "Template $(basename $template) exists"
    else
        print_warning "Template $(basename $template) missing"
    fi
done

echo ""
echo "9. Checking common GitLab CI patterns..."

# Check for include statements
if grep -q "include:" .gitlab-ci.yml; then
    print_status 0 "Uses include pattern for modularity"
else
    print_warning "No include statements found - consider modularizing"
fi

# Check for cache configuration
if grep -q "cache:" .gitlab-ci.yml .gitlab/ci/*.yml 2>/dev/null; then
    print_status 0 "Cache configuration found"
else
    print_warning "No cache configuration - builds may be slower"
fi

# Check for artifacts
if grep -q "artifacts:" .gitlab-ci.yml .gitlab/ci/*.yml 2>/dev/null; then
    print_status 0 "Artifacts configuration found"
else
    print_warning "No artifacts configuration found"
fi

echo ""
echo "10. Security checks..."

# Check for hardcoded secrets
if grep -r -i "password\|secret\|key\|token" .gitlab-ci.yml .gitlab/ci/*.yml 2>/dev/null | grep -v "\$" | grep -v "variables:" >/dev/null; then
    print_status 1 "Potential hardcoded secrets found"
else
    print_status 0 "No hardcoded secrets detected"
fi

# Check for security scanning jobs
if grep -q "sast\|dependency.*scan\|container.*scan" .gitlab-ci.yml .gitlab/ci/*.yml 2>/dev/null; then
    print_status 0 "Security scanning jobs configured"
else
    print_warning "No security scanning jobs found"
fi

echo ""
echo "========================================"
echo "📊 Validation Summary:"
echo "========================================"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}🎉 All checks passed! GitLab CI configuration is ready.${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Configuration is valid but has $WARNINGS warnings.${NC}"
    exit 0
else
    echo -e "${RED}❌ Found $ERRORS errors and $WARNINGS warnings.${NC}"
    echo ""
    echo "🔧 Quick fixes:"
    echo "- Install missing tools: pip install yamllint && npm install -g @gitlab/cli"
    echo "- Create missing files using the templates provided"
    echo "- Fix YAML syntax errors"
    echo "- Add missing Dockerfiles for services"
    exit 1
fi

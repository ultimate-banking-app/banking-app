#!/bin/bash

echo "🔍 Banking Application - Complete Configuration Validation"
echo "=========================================================="

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TOTAL_ERRORS=0
TOTAL_WARNINGS=0

print_header() {
    echo -e "\n${BLUE}$1${NC}"
    echo "$(printf '=%.0s' {1..50})"
}

run_validation() {
    local script_name=$1
    local description=$2
    
    if [ -f "./scripts/$script_name" ]; then
        echo -e "${YELLOW}Running $description...${NC}"
        if ./scripts/$script_name; then
            echo -e "${GREEN}✅ $description completed successfully${NC}"
        else
            echo -e "${RED}❌ $description failed${NC}"
            ((TOTAL_ERRORS++))
        fi
    else
        echo -e "${RED}❌ $script_name not found${NC}"
        ((TOTAL_ERRORS++))
    fi
    echo ""
}

# Start validation
echo "Starting comprehensive validation of Banking Application..."
echo ""

print_header "📁 File Structure Validation"
echo "Checking project structure..."

REQUIRED_DIRS=(
    "auth-service"
    "account-service" 
    "payment-service"
    "api-gateway"
    "banking-ui"
    "shared"
    "scripts"
    "helm"
    ".github/workflows"
    ".gitlab/ci"
    "jenkins-shared-library"
    "interview-ready"
    "observability"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✅ Directory $dir exists${NC}"
    else
        echo -e "${RED}❌ Directory $dir missing${NC}"
        ((TOTAL_ERRORS++))
    fi
done

REQUIRED_FILES=(
    "README.md"
    "ARCHITECTURE.md"
    "DEPLOYMENT.md"
    "API.md"
    "KUBERNETES.md"
    "pom.xml"
    "docker-compose.yml"
    "docker-compose-db.yml"
    "Jenkinsfile"
    ".gitlab-ci.yml"
    "start-services.sh"
    "stop-services.sh"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ File $file exists${NC}"
    else
        echo -e "${RED}❌ File $file missing${NC}"
        ((TOTAL_ERRORS++))
    fi
done

print_header "🔧 Jenkins Configuration Validation"
if [ -f "Jenkinsfile" ]; then
    echo -e "${GREEN}✅ Jenkinsfile exists${NC}"
    
    # Check Jenkins shared library
    if [ -d "jenkins-shared-library" ]; then
        echo -e "${GREEN}✅ Jenkins shared library exists${NC}"
        
        JENKINS_FILES=("vars/bankingBuild.groovy" "vars/bankingQuality.groovy" "vars/bankingDocker.groovy" "vars/bankingUtils.groovy")
        for file in "${JENKINS_FILES[@]}"; do
            if [ -f "jenkins-shared-library/$file" ]; then
                echo -e "${GREEN}✅ $file exists${NC}"
            else
                echo -e "${RED}❌ $file missing${NC}"
                ((TOTAL_ERRORS++))
            fi
        done
    else
        echo -e "${RED}❌ Jenkins shared library missing${NC}"
        ((TOTAL_ERRORS++))
    fi
else
    echo -e "${RED}❌ Jenkinsfile missing${NC}"
    ((TOTAL_ERRORS++))
fi

print_header "🦊 GitLab CI Configuration Validation"
run_validation "validate-gitlab-ci.sh" "GitLab CI validation"

print_header "🐙 GitHub Actions Configuration Validation"
run_validation "validate-github-actions.sh" "GitHub Actions validation"

print_header "🐳 Docker Configuration Validation"
echo "Checking Docker configurations..."

SERVICES=("auth-service" "account-service" "payment-service" "api-gateway")
for service in "${SERVICES[@]}"; do
    if [ -f "$service/Dockerfile" ]; then
        echo -e "${GREEN}✅ $service Dockerfile exists${NC}"
        
        # Basic Dockerfile validation
        if grep -q "FROM\|COPY\|EXPOSE" "$service/Dockerfile"; then
            echo -e "${GREEN}✅ $service Dockerfile has basic structure${NC}"
        else
            echo -e "${YELLOW}⚠️  $service Dockerfile may be incomplete${NC}"
            ((TOTAL_WARNINGS++))
        fi
    else
        echo -e "${RED}❌ $service Dockerfile missing${NC}"
        ((TOTAL_ERRORS++))
    fi
done

# Check docker-compose files
if [ -f "docker-compose.yml" ]; then
    echo -e "${GREEN}✅ docker-compose.yml exists${NC}"
else
    echo -e "${RED}❌ docker-compose.yml missing${NC}"
    ((TOTAL_ERRORS++))
fi

if [ -f "docker-compose-db.yml" ]; then
    echo -e "${GREEN}✅ docker-compose-db.yml exists${NC}"
else
    echo -e "${RED}❌ docker-compose-db.yml missing${NC}"
    ((TOTAL_ERRORS++))
fi

print_header "☸️ Kubernetes Configuration Validation"
echo "Checking Kubernetes configurations..."

if [ -d "helm" ]; then
    echo -e "${GREEN}✅ Helm directory exists${NC}"
    
    if [ -f "helm/banking-app/Chart.yaml" ]; then
        echo -e "${GREEN}✅ Helm Chart.yaml exists${NC}"
    else
        echo -e "${RED}❌ Helm Chart.yaml missing${NC}"
        ((TOTAL_ERRORS++))
    fi
    
    if [ -f "helm/banking-app/values.yaml" ]; then
        echo -e "${GREEN}✅ Helm values.yaml exists${NC}"
    else
        echo -e "${RED}❌ Helm values.yaml missing${NC}"
        ((TOTAL_ERRORS++))
    fi
else
    echo -e "${RED}❌ Helm directory missing${NC}"
    ((TOTAL_ERRORS++))
fi

print_header "📊 Observability Configuration Validation"
echo "Checking observability configurations..."

OBSERVABILITY_FILES=(
    "observability/prometheus/prometheus.yaml"
    "observability/grafana/grafana.yaml"
    "observability/README.md"
    "observability/CUSTOM-METRICS-IMPLEMENTATION.md"
)

for file in "${OBSERVABILITY_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ $file exists${NC}"
    else
        echo -e "${YELLOW}⚠️  $file missing${NC}"
        ((TOTAL_WARNINGS++))
    fi
done

print_header "🔒 Security Configuration Validation"
echo "Checking security configurations..."

# Check for hardcoded secrets
echo "Scanning for potential hardcoded secrets..."
if grep -r -i "password\|secret\|key\|token" --include="*.yml" --include="*.yaml" --include="*.properties" . | grep -v "\$" | grep -v "example" | grep -v "placeholder" >/dev/null 2>&1; then
    echo -e "${RED}❌ Potential hardcoded secrets found${NC}"
    ((TOTAL_ERRORS++))
else
    echo -e "${GREEN}✅ No hardcoded secrets detected${NC}"
fi

# Check for security scanning configurations
SECURITY_CONFIGS=(
    ".github/workflows/security.yml"
    ".gitlab/ci/security.yml"
)

for config in "${SECURITY_CONFIGS[@]}"; do
    if [ -f "$config" ]; then
        echo -e "${GREEN}✅ Security scanning configured in $config${NC}"
    else
        echo -e "${YELLOW}⚠️  Security scanning not configured in $config${NC}"
        ((TOTAL_WARNINGS++))
    fi
done

print_header "📚 Documentation Validation"
echo "Checking documentation completeness..."

DOCS=(
    "README.md"
    "ARCHITECTURE.md"
    "DEPLOYMENT.md"
    "API.md"
    "KUBERNETES.md"
    "JENKINS.md"
    "GITLAB-CI.md"
    "GITHUB-ACTIONS.md"
)

for doc in "${DOCS[@]}"; do
    if [ -f "$doc" ]; then
        echo -e "${GREEN}✅ $doc exists${NC}"
        
        # Check if file has content
        if [ -s "$doc" ]; then
            echo -e "${GREEN}✅ $doc has content${NC}"
        else
            echo -e "${YELLOW}⚠️  $doc is empty${NC}"
            ((TOTAL_WARNINGS++))
        fi
    else
        echo -e "${RED}❌ $doc missing${NC}"
        ((TOTAL_ERRORS++))
    fi
done

# Check interview-ready documentation
if [ -d "interview-ready" ]; then
    echo -e "${GREEN}✅ Interview-ready documentation exists${NC}"
    
    INTERVIEW_DIRS=("architecture" "cicd" "monitoring" "microservices" "security" "performance")
    for dir in "${INTERVIEW_DIRS[@]}"; do
        if [ -d "interview-ready/$dir" ]; then
            echo -e "${GREEN}✅ Interview docs for $dir exist${NC}"
        else
            echo -e "${YELLOW}⚠️  Interview docs for $dir missing${NC}"
            ((TOTAL_WARNINGS++))
        fi
    done
else
    echo -e "${RED}❌ Interview-ready documentation missing${NC}"
    ((TOTAL_ERRORS++))
fi

print_header "🧪 Testing Configuration Validation"
echo "Checking testing configurations..."

# Check for test files
for service in "${SERVICES[@]}"; do
    if [ -d "$service/src/test" ]; then
        echo -e "${GREEN}✅ $service has test directory${NC}"
    else
        echo -e "${YELLOW}⚠️  $service missing test directory${NC}"
        ((TOTAL_WARNINGS++))
    fi
done

# Check frontend tests
if [ -d "banking-ui/src" ]; then
    if [ -f "banking-ui/package.json" ] && grep -q "test" "banking-ui/package.json"; then
        echo -e "${GREEN}✅ Frontend test scripts configured${NC}"
    else
        echo -e "${YELLOW}⚠️  Frontend test scripts not configured${NC}"
        ((TOTAL_WARNINGS++))
    fi
fi

print_header "🔧 Build Configuration Validation"
echo "Checking build configurations..."

# Check Maven configuration
if [ -f "pom.xml" ]; then
    echo -e "${GREEN}✅ Root pom.xml exists${NC}"
    
    # Check for required properties
    if grep -q "<java.version>" pom.xml; then
        echo -e "${GREEN}✅ Java version specified${NC}"
    else
        echo -e "${YELLOW}⚠️  Java version not specified${NC}"
        ((TOTAL_WARNINGS++))
    fi
    
    if grep -q "<spring-boot.version>" pom.xml; then
        echo -e "${GREEN}✅ Spring Boot version specified${NC}"
    else
        echo -e "${YELLOW}⚠️  Spring Boot version not specified${NC}"
        ((TOTAL_WARNINGS++))
    fi
else
    echo -e "${RED}❌ Root pom.xml missing${NC}"
    ((TOTAL_ERRORS++))
fi

# Check Node.js configuration
if [ -f "banking-ui/package.json" ]; then
    echo -e "${GREEN}✅ Frontend package.json exists${NC}"
    
    # Check for required scripts
    if grep -q "\"build\":\|\"test\":\|\"lint\":" "banking-ui/package.json"; then
        echo -e "${GREEN}✅ Required npm scripts found${NC}"
    else
        echo -e "${YELLOW}⚠️  Some npm scripts may be missing${NC}"
        ((TOTAL_WARNINGS++))
    fi
else
    echo -e "${RED}❌ Frontend package.json missing${NC}"
    ((TOTAL_ERRORS++))
fi

print_header "📊 Final Validation Summary"
echo "=========================================================="

if [ $TOTAL_ERRORS -eq 0 ] && [ $TOTAL_WARNINGS -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL VALIDATIONS PASSED!${NC}"
    echo -e "${GREEN}✅ Banking Application configuration is complete and ready for deployment.${NC}"
    echo ""
    echo "🚀 Next steps:"
    echo "1. Set up CI/CD pipeline secrets and variables"
    echo "2. Configure Kubernetes cluster access"
    echo "3. Deploy observability stack: kubectl apply -k observability"
    echo "4. Deploy to development environment"
    exit 0
elif [ $TOTAL_ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  VALIDATION COMPLETED WITH WARNINGS${NC}"
    echo -e "${YELLOW}Found $TOTAL_WARNINGS warnings that should be addressed.${NC}"
    echo ""
    echo "🔧 Recommended actions:"
    echo "- Review and address all warnings"
    echo "- Complete missing documentation"
    echo "- Add missing test configurations"
    echo "- Deploy observability stack: kubectl apply -k observability"
    exit 0
else
    echo -e "${RED}❌ VALIDATION FAILED${NC}"
    echo -e "${RED}Found $TOTAL_ERRORS errors and $TOTAL_WARNINGS warnings.${NC}"
    echo ""
    echo "🔧 Required fixes:"
    echo "- Create missing files and directories"
    echo "- Fix configuration errors"
    echo "- Complete required documentation"
    echo "- Add missing Dockerfiles and CI/CD configurations"
    echo ""
    echo "💡 Quick fixes available:"
    echo "- Run: ./scripts/create-missing-dockerfiles.sh"
    echo "- Install missing tools: pip install yamllint"
    echo "- Set up Git repository if not already done"
    exit 1
fi

#!/bin/bash

echo "🔍 GitHub Actions Configuration Validation"
echo "=========================================="

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

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

echo "1. Checking workflow files..."

WORKFLOWS=("ci-cd.yml" "pr-review.yml" "security.yml" "release.yml")
for workflow in "${WORKFLOWS[@]}"; do
    if [ -f ".github/workflows/$workflow" ]; then
        print_status 0 "Workflow $workflow exists"
    else
        print_status 1 "Workflow $workflow missing"
    fi
done

echo ""
echo "2. Checking reusable actions..."

ACTIONS=("setup-java" "setup-node")
for action in "${ACTIONS[@]}"; do
    if [ -f ".github/actions/$action/action.yml" ]; then
        print_status 0 "Action $action exists"
    else
        print_status 1 "Action $action missing"
    fi
done

echo ""
echo "3. Validating YAML syntax..."

if command -v yamllint >/dev/null 2>&1; then
    for workflow in "${WORKFLOWS[@]}"; do
        if [ -f ".github/workflows/$workflow" ]; then
            yamllint ".github/workflows/$workflow" >/dev/null 2>&1
            print_status $? "Workflow $workflow syntax"
        fi
    done
    
    for action in "${ACTIONS[@]}"; do
        if [ -f ".github/actions/$action/action.yml" ]; then
            yamllint ".github/actions/$action/action.yml" >/dev/null 2>&1
            print_status $? "Action $action syntax"
        fi
    done
else
    print_warning "yamllint not installed - install with: pip install yamllint"
fi

echo ""
echo "4. Checking GitHub CLI integration..."

if command -v gh >/dev/null 2>&1; then
    # Check if authenticated
    if gh auth status >/dev/null 2>&1; then
        print_status 0 "GitHub CLI authenticated"
        
        # Validate workflows if in a git repo
        if [ -d ".git" ]; then
            for workflow in "${WORKFLOWS[@]}"; do
                if [ -f ".github/workflows/$workflow" ]; then
                    gh workflow view "$workflow" >/dev/null 2>&1
                    print_status $? "Workflow $workflow validation"
                fi
            done
        else
            print_warning "Not in a git repository - cannot validate workflows"
        fi
    else
        print_warning "GitHub CLI not authenticated - run: gh auth login"
    fi
else
    print_warning "GitHub CLI not installed - install from: https://cli.github.com"
fi

echo ""
echo "5. Checking required files..."

REQUIRED_FILES=("Dockerfile" "Dockerfile" "Dockerfile" "Dockerfile")
SERVICES=("auth-service" "account-service" "payment-service" "api-gateway")

for i in "${!SERVICES[@]}"; do
    service="${SERVICES[$i]}"
    if [ -f "$service/Dockerfile" ]; then
        print_status 0 "Dockerfile exists for $service"
    else
        print_status 1 "Dockerfile missing for $service"
    fi
done

echo ""
echo "6. Checking Kubernetes manifests..."

K8S_DIRS=("k8s/dev" "k8s/staging" "k8s/prod")
for dir in "${K8S_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        print_status 0 "K8s manifests exist for $dir"
    else
        print_warning "K8s manifests missing for $dir"
    fi
done

echo ""
echo "7. Checking Helm charts..."

if [ -f "helm/banking-app/Chart.yaml" ]; then
    print_status 0 "Helm Chart.yaml exists"
else
    print_status 1 "Helm Chart.yaml missing"
fi

if [ -f "helm/banking-app/values.yaml" ]; then
    print_status 0 "Helm values.yaml exists"
else
    print_status 1 "Helm values.yaml missing"
fi

echo ""
echo "8. Validating workflow patterns..."

# Check for change detection
if grep -q "dorny/paths-filter" .github/workflows/ci-cd.yml 2>/dev/null; then
    print_status 0 "Change detection configured"
else
    print_warning "Change detection not found"
fi

# Check for caching
if grep -q "cache:" .github/workflows/*.yml 2>/dev/null; then
    print_status 0 "Caching configured"
else
    print_warning "No caching configuration found"
fi

# Check for security scanning
if grep -q "security-events: write" .github/workflows/security.yml 2>/dev/null; then
    print_status 0 "Security scanning permissions configured"
else
    print_warning "Security scanning permissions not found"
fi

# Check for environments
if grep -q "environment:" .github/workflows/*.yml 2>/dev/null; then
    print_status 0 "GitHub Environments configured"
else
    print_warning "GitHub Environments not configured"
fi

echo ""
echo "9. Security checks..."

# Check for hardcoded secrets
if grep -r -i "password\|secret\|key\|token" .github/workflows/*.yml 2>/dev/null | grep -v "\${{" | grep -v "secrets\." >/dev/null; then
    print_status 1 "Potential hardcoded secrets found"
else
    print_status 0 "No hardcoded secrets detected"
fi

# Check for proper secret usage
if grep -q "secrets\." .github/workflows/*.yml 2>/dev/null; then
    print_status 0 "GitHub Secrets properly used"
else
    print_warning "No GitHub Secrets usage found"
fi

echo ""
echo "10. Testing workflow triggers..."

# Check for proper triggers
EXPECTED_TRIGGERS=("push:" "pull_request:" "release:" "workflow_dispatch:")
for trigger in "${EXPECTED_TRIGGERS[@]}"; do
    if grep -q "$trigger" .github/workflows/*.yml 2>/dev/null; then
        print_status 0 "Trigger '$trigger' configured"
    else
        print_warning "Trigger '$trigger' not found"
    fi
done

echo ""
echo "========================================"
echo "📊 Validation Summary:"
echo "========================================"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}🎉 All checks passed! GitHub Actions configuration is ready.${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Configuration is valid but has $WARNINGS warnings.${NC}"
    echo ""
    echo "🔧 Recommendations:"
    echo "- Install missing tools for full validation"
    echo "- Create missing Kubernetes manifests"
    echo "- Set up GitHub Environments in repository settings"
    exit 0
else
    echo -e "${RED}❌ Found $ERRORS errors and $WARNINGS warnings.${NC}"
    echo ""
    echo "🔧 Required fixes:"
    echo "- Create missing workflow files"
    echo "- Add missing Dockerfiles"
    echo "- Fix YAML syntax errors"
    echo "- Create Helm charts"
    echo ""
    echo "💡 Quick fixes:"
    echo "- Run: ./scripts/create-missing-dockerfiles.sh"
    echo "- Install: pip install yamllint"
    echo "- Install: gh auth login"
    exit 1
fi

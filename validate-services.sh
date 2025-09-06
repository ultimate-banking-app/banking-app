#!/bin/bash

echo "🔍 Banking Application - Service Validation"
echo "==========================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

TOTAL_ERRORS=0

# Services to validate
SERVICES=("shared" "auth-service" "account-service" "audit-service" "balance-service" "deposit-service" "api-gateway")

print_info "Validating service structure and code..."
echo ""

for service in "${SERVICES[@]}"; do
    echo "Checking $service..."
    
    # Check directory exists
    if [ ! -d "$service" ]; then
        print_status 1 "$service directory missing"
        ((TOTAL_ERRORS++))
        continue
    fi
    
    # Check pom.xml
    if [ ! -f "$service/pom.xml" ]; then
        print_status 1 "$service/pom.xml missing"
        ((TOTAL_ERRORS++))
    else
        print_status 0 "$service/pom.xml exists"
    fi
    
    # Check main application class (skip for shared)
    if [ "$service" != "shared" ]; then
        if find "$service/src/main/java" -name "*Application.java" | grep -q .; then
            print_status 0 "$service main application class exists"
        else
            print_status 1 "$service main application class missing"
            ((TOTAL_ERRORS++))
        fi
        
        # Check application.yml
        if [ -f "$service/src/main/resources/application.yml" ]; then
            print_status 0 "$service application.yml exists"
        else
            print_status 1 "$service application.yml missing"
            ((TOTAL_ERRORS++))
        fi
        
        # Check controller exists (except for shared)
        if find "$service/src/main/java" -name "*Controller.java" | grep -q .; then
            print_status 0 "$service controller exists"
        else
            print_status 1 "$service controller missing"
            ((TOTAL_ERRORS++))
        fi
    fi
    
    echo ""
done

print_info "Checking database configuration..."

# Check database init script
if [ -f "k8s/base/configmap.yaml" ]; then
    print_status 0 "Database initialization script exists"
else
    print_status 1 "Database initialization script missing"
    ((TOTAL_ERRORS++))
fi

print_info "Checking UI configuration..."

# Check UI files
if [ -f "banking-ui/src/App.vue" ]; then
    print_status 0 "Banking UI App.vue exists"
else
    print_status 1 "Banking UI App.vue missing"
    ((TOTAL_ERRORS++))
fi

if [ -f "banking-ui/package.json" ]; then
    print_status 0 "Banking UI package.json exists"
else
    print_status 1 "Banking UI package.json missing"
    ((TOTAL_ERRORS++))
fi

echo ""
echo "📊 Validation Summary:"
echo "====================="

if [ $TOTAL_ERRORS -eq 0 ]; then
    echo -e "${GREEN}🎉 All validations passed!${NC}"
    echo ""
    echo "🚀 Ready to build and test:"
    echo "  ./test-and-build.sh  # Build and test all services"
    echo "  ./quick-start.sh     # Start the application"
    exit 0
else
    echo -e "${RED}❌ Found $TOTAL_ERRORS validation errors${NC}"
    echo ""
    echo "🔧 Fix the errors above before proceeding"
    exit 1
fi

#!/bin/bash

echo "🔨 Banking Application - Test and Build"
echo "======================================="

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

# Create logs directory
mkdir -p logs

# Services to build and test (in dependency order)
SERVICES=("shared" "auth-service" "account-service" "audit-service" "balance-service" "api-gateway")

# Services with complete tests
SERVICES_WITH_TESTS=("auth-service" "account-service" "audit-service" "balance-service")

TOTAL_SERVICES=${#SERVICES[@]}
BUILT_SERVICES=0
FAILED_SERVICES=0

echo "Building and testing $TOTAL_SERVICES services..."
echo ""

for service in "${SERVICES[@]}"; do
    if [ -d "$service" ]; then
        print_info "Building $service..."
        cd "$service"
        
        # Check if service has complete tests
        if [[ " ${SERVICES_WITH_TESTS[@]} " =~ " ${service} " ]]; then
            # Build with tests
            if mvn clean compile test package -q > "../logs/build-$service.log" 2>&1; then
                print_status 0 "$service built and tested successfully"
                ((BUILT_SERVICES++))
            else
                print_status 1 "$service failed (check logs/build-$service.log)"
                ((FAILED_SERVICES++))
            fi
        else
            # Build without tests for incomplete services
            if mvn clean compile package -DskipTests -q > "../logs/build-$service.log" 2>&1; then
                print_status 0 "$service built successfully (tests skipped)"
                ((BUILT_SERVICES++))
            else
                print_status 1 "$service failed (check logs/build-$service.log)"
                ((FAILED_SERVICES++))
            fi
        fi
        
        cd ..
    else
        print_status 1 "$service directory not found"
        ((FAILED_SERVICES++))
    fi
done

echo ""
echo "📊 Build Summary:"
echo "================="
echo -e "${GREEN}✅ Successfully built: $BUILT_SERVICES/$TOTAL_SERVICES${NC}"

if [ $FAILED_SERVICES -gt 0 ]; then
    echo -e "${RED}❌ Failed builds: $FAILED_SERVICES/$TOTAL_SERVICES${NC}"
    echo ""
    echo "🔧 Check build logs in logs/ directory for details"
    exit 1
else
    echo -e "${GREEN}🎉 All services built successfully!${NC}"
    echo ""
    echo "📋 Test Status:"
    echo "  ✅ Tested: ${SERVICES_WITH_TESTS[*]}"
    echo "  ⏭️  Skipped: api-gateway, shared"
    echo ""
    echo "🚀 Next steps:"
    echo "  ./quick-start.sh    # Start essential services"
    echo "  ./test-services.sh  # Test the running application"
    exit 0
fi

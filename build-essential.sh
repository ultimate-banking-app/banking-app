#!/bin/bash

echo "🔨 Building Essential Banking Services"
echo "====================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

# Essential services for basic functionality
ESSENTIAL_SERVICES=("shared" "auth-service" "account-service" "audit-service" "balance-service" "api-gateway")

echo "Building essential services for quick start..."
echo ""

FAILED=0

for service in "${ESSENTIAL_SERVICES[@]}"; do
    if [ -d "$service" ]; then
        echo -n "Building $service... "
        cd "$service"
        
        if mvn clean package -DskipTests -q > ../logs/build-$service.log 2>&1; then
            print_status 0 "$service"
        else
            print_status 1 "$service (check logs/build-$service.log)"
            ((FAILED++))
        fi
        
        cd ..
    else
        echo -e "${YELLOW}⚠️  $service directory not found${NC}"
    fi
done

echo ""
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All essential services built successfully!${NC}"
    echo ""
    echo "🚀 Next steps:"
    echo "  ./quick-start.sh    # Start essential services"
    echo "  ./test-services.sh  # Test the application"
else
    echo -e "${RED}❌ $FAILED service(s) failed to build${NC}"
    echo ""
    echo "🔧 Check build logs in logs/ directory"
fi

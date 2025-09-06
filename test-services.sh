#!/bin/bash

echo "🧪 Testing Banking Application Services"
echo "======================================"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test service health
test_service() {
    local service=$1
    local port=$2
    
    echo -n "Testing $service ($port)... "
    
    if curl -s "http://localhost:$port/actuator/health" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ OK${NC}"
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        return 1
    fi
}

# Test UI
test_ui() {
    echo -n "Testing Banking UI (3000)... "
    
    if curl -s "http://localhost:3000" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ OK${NC}"
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        return 1
    fi
}

echo "🔍 Health Check Tests:"
echo "====================="

# Test all services
SERVICES=(
    "Auth Service:8081"
    "Account Service:8084"
    "Payment Service:8083"
    "Audit Service:8085"
    "Balance Service:8086"
    "API Gateway:8090"
)

FAILED=0

for service_info in "${SERVICES[@]}"; do
    IFS=':' read -r service port <<< "$service_info"
    if ! test_service "$service" "$port"; then
        ((FAILED++))
    fi
done

# Test UI
if ! test_ui; then
    ((FAILED++))
fi

echo ""
echo "📊 API Tests:"
echo "============="

# Test login
echo -n "Testing login API... "
LOGIN_RESPONSE=$(curl -s -X POST "http://localhost:8090/api/auth/login" \
    -H "Content-Type: application/json" \
    -d '{"username":"john.doe","password":"password"}' 2>/dev/null)

if echo "$LOGIN_RESPONSE" | grep -q "token"; then
    echo -e "${GREEN}✅ OK${NC}"
    TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
else
    echo -e "${RED}❌ FAILED${NC}"
    ((FAILED++))
    TOKEN=""
fi

# Test accounts API if we have a token
if [ ! -z "$TOKEN" ]; then
    echo -n "Testing accounts API... "
    ACCOUNTS_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "http://localhost:8090/api/accounts" 2>/dev/null)
    
    if echo "$ACCOUNTS_RESPONSE" | grep -q "accountNumber"; then
        echo -e "${GREEN}✅ OK${NC}"
    else
        echo -e "${RED}❌ FAILED${NC}"
        ((FAILED++))
    fi
fi

echo ""
echo "📋 Summary:"
echo "==========="

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed! Banking application is working correctly.${NC}"
    echo ""
    echo "🌐 Access URLs:"
    echo "  Banking UI: http://localhost:3000"
    echo "  API Gateway: http://localhost:8090"
    echo ""
    echo "👤 Demo credentials:"
    echo "  john.doe / password"
    echo "  jane.smith / password"
    echo "  admin / password"
else
    echo -e "${RED}❌ $FAILED test(s) failed. Please check the services.${NC}"
    echo ""
    echo "🔧 Troubleshooting:"
    echo "  1. Make sure all services are running: ./start-all-services.sh"
    echo "  2. Check service logs: tail -f logs/[service-name].log"
    echo "  3. Verify database is running: docker-compose -f docker-compose-db.yml ps"
fi

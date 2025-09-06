#!/bin/bash

echo "🔨 Building Banking Application with Coverage"
echo "============================================="

GREEN='\033[0;32m'
RED='\033[0;31m'
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

mkdir -p logs coverage-reports

SERVICES=("shared" "auth-service" "account-service" "audit-service" "balance-service" "deposit-service" "notification-service" "transfer-service" "withdrawal-service" "api-gateway")
SERVICES_WITH_TESTS=("auth-service" "account-service" "audit-service" "balance-service" "deposit-service" "notification-service" "transfer-service" "withdrawal-service")
BUILT=0
FAILED=0

for service in "${SERVICES[@]}"; do
    if [ -d "$service" ]; then
        echo "Building $service..."
        cd "$service"
        
        if [[ " ${SERVICES_WITH_TESTS[@]} " =~ " ${service} " ]]; then
            # Build with tests and coverage
            if mvn clean compile test jacoco:report package -q > "../logs/build-$service.log" 2>&1; then
                print_status 0 "$service (with coverage)"
                # Copy coverage report
                if [ -d "target/site/jacoco" ]; then
                    cp -r target/site/jacoco "../coverage-reports/$service-coverage"
                fi
                ((BUILT++))
            else
                print_status 1 "$service (check logs/build-$service.log)"
                ((FAILED++))
            fi
        else
            # Build without tests
            if mvn clean package -DskipTests -q > "../logs/build-$service.log" 2>&1; then
                print_status 0 "$service (no tests)"
                ((BUILT++))
            else
                print_status 1 "$service (check logs/build-$service.log)"
                ((FAILED++))
            fi
        fi
        
        cd ..
    fi
done

echo ""
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All $BUILT services built with coverage reports!${NC}"
    echo ""
    echo "📊 Coverage Reports:"
    for service in "${SERVICES_WITH_TESTS[@]}"; do
        if [ -d "coverage-reports/$service-coverage" ]; then
            echo "  📈 $service: coverage-reports/$service-coverage/index.html"
        fi
    done
    echo ""
    echo "🎯 Coverage Summary:"
    echo "  View individual service coverage reports above"
    echo "  Aim for >80% line coverage, >70% branch coverage"
    exit 0
else
    echo -e "${RED}❌ $FAILED service(s) failed to build${NC}"
    exit 1
fi

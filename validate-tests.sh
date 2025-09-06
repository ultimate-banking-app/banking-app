#!/bin/bash

echo "🧪 Banking Application - Test Validation"
echo "========================================"

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

# Services with tests
SERVICES_WITH_TESTS=("auth-service" "account-service" "audit-service" "balance-service")

print_info "Validating test structure..."
echo ""

for service in "${SERVICES_WITH_TESTS[@]}"; do
    echo "Checking $service tests..."
    
    # Check test directory structure
    if [ -d "$service/src/test/java" ]; then
        print_status 0 "$service test directory exists"
    else
        print_status 1 "$service test directory missing"
        ((TOTAL_ERRORS++))
    fi
    
    # Check for exactly one test file per service
    TEST_FILES=$(find "$service/src/test/java" -name "*Test.java" | wc -l)
    if [ "$TEST_FILES" -eq 1 ]; then
        TEST_FILE=$(find "$service/src/test/java" -name "*Test.java")
        print_status 0 "$service has one test file: $(basename $TEST_FILE)"
    elif [ "$TEST_FILES" -eq 0 ]; then
        print_status 1 "$service has no test files"
        ((TOTAL_ERRORS++))
    else
        print_status 1 "$service has multiple test files ($TEST_FILES)"
        find "$service/src/test/java" -name "*Test.java" | while read file; do
            echo "  - $(basename $file)"
        done
        ((TOTAL_ERRORS++))
    fi
    
    echo ""
done

print_info "Checking for duplicate or conflicting tests..."

# Check for common duplicate patterns
DUPLICATE_PATTERNS=("ControllerTest" "ServiceTest")
for service in "${SERVICES_WITH_TESTS[@]}"; do
    for pattern in "${DUPLICATE_PATTERNS[@]}"; do
        PATTERN_COUNT=$(find "$service/src/test/java" -name "*${pattern}.java" | wc -l)
        if [ "$PATTERN_COUNT" -gt 1 ]; then
            print_status 1 "$service has multiple ${pattern} files"
            ((TOTAL_ERRORS++))
        fi
    done
done

echo ""
echo "📊 Test Validation Summary:"
echo "=========================="

if [ $TOTAL_ERRORS -eq 0 ]; then
    echo -e "${GREEN}🎉 All test validations passed!${NC}"
    echo ""
    echo "📋 Test Structure:"
    for service in "${SERVICES_WITH_TESTS[@]}"; do
        TEST_FILE=$(find "$service/src/test/java" -name "*Test.java" 2>/dev/null | head -1)
        if [ -n "$TEST_FILE" ]; then
            echo "  ✅ $service: $(basename $TEST_FILE)"
        fi
    done
    echo ""
    echo "🚀 Ready to build and test:"
    echo "  ./test-and-build.sh  # Build and test all services"
    exit 0
else
    echo -e "${RED}❌ Found $TOTAL_ERRORS test validation errors${NC}"
    echo ""
    echo "🔧 Fix the duplicate or missing test files above"
    exit 1
fi

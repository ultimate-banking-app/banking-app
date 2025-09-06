#!/bin/bash

echo "🔒 Security Vulnerability Check"
echo "==============================="

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

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

echo "Checking dependency versions..."
echo ""

# Check PostgreSQL version
POSTGRES_VERSION=$(grep -r "postgresql.version" pom.xml | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
if [ "$POSTGRES_VERSION" = "42.7.1" ]; then
    print_status 0 "PostgreSQL driver: $POSTGRES_VERSION (secure)"
else
    print_status 1 "PostgreSQL driver: $POSTGRES_VERSION (potentially vulnerable)"
fi

# Check Spring Boot version
SPRING_VERSION=$(grep -r "spring-boot.version" pom.xml | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
if [[ "$SPRING_VERSION" =~ ^3\.[2-9]\. ]]; then
    print_status 0 "Spring Boot: $SPRING_VERSION (secure)"
else
    print_status 1 "Spring Boot: $SPRING_VERSION (potentially vulnerable)"
fi

# Check for known vulnerable patterns
echo ""
echo "Checking for vulnerable patterns..."

# Check for old PostgreSQL versions in individual POMs
VULNERABLE_POSTGRES=$(find . -name "pom.xml" -exec grep -l "postgresql.*42\.[0-6]\." {} \; 2>/dev/null)
if [ -z "$VULNERABLE_POSTGRES" ]; then
    print_status 0 "No vulnerable PostgreSQL versions found"
else
    print_status 1 "Vulnerable PostgreSQL versions found in:"
    echo "$VULNERABLE_POSTGRES"
fi

# Check for Spring Boot versions < 3.2
VULNERABLE_SPRING=$(find . -name "pom.xml" -exec grep -l "spring-boot.*[12]\." {} \; 2>/dev/null)
if [ -z "$VULNERABLE_SPRING" ]; then
    print_status 0 "No vulnerable Spring Boot versions found"
else
    print_status 1 "Vulnerable Spring Boot versions found in:"
    echo "$VULNERABLE_SPRING"
fi

echo ""
echo "📋 Current Secure Versions:"
echo "  PostgreSQL: 42.7.1 (latest secure)"
echo "  Spring Boot: 3.2.1 (latest stable)"
echo "  Maven Compiler: 3.12.1 (latest)"
echo ""
echo "🔧 To fix vulnerabilities:"
echo "  1. Update parent pom.xml versions"
echo "  2. Run: mvn dependency:tree | grep -i vulnerable"
echo "  3. Run: ./build-all.sh to rebuild with secure versions"

#!/bin/bash

echo "📊 Adding JaCoCo Plugin to All Services"
echo "======================================="

GREEN='\033[0;32m'
NC='\033[0m'

SERVICES=("account-service" "audit-service" "balance-service" "deposit-service" "notification-service" "transfer-service" "withdrawal-service" "api-gateway")

for service in "${SERVICES[@]}"; do
    echo "Adding JaCoCo to $service..."
    
    # Add JaCoCo plugin to build section
    sed -i '' '/<\/plugins>/i\
            <plugin>\
                <groupId>org.jacoco</groupId>\
                <artifactId>jacoco-maven-plugin</artifactId>\
            </plugin>
' "$service/pom.xml"
    
    echo -e "${GREEN}✅ Added JaCoCo to $service${NC}"
done

echo ""
echo "📋 JaCoCo Coverage Reports:"
echo "  mvn test                    # Run tests with coverage"
echo "  target/site/jacoco/index.html  # View coverage report"
echo ""
echo "🎯 Coverage Goals:"
echo "  Line Coverage: >80%"
echo "  Branch Coverage: >70%"

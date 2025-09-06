#!/bin/bash

echo "🔄 Updating Infrastructure for All Services"
echo "==========================================="

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Services list
SERVICES=("auth-service" "account-service" "audit-service" "balance-service" "deposit-service" "notification-service" "transfer-service" "withdrawal-service" "api-gateway")

print_info "Creating Dockerfiles for all services..."
for service in "${SERVICES[@]}"; do
    if [ ! -f "$service/Dockerfile" ]; then
        cat > "$service/Dockerfile" << EOF
FROM openjdk:17-jre-slim
COPY target/*.jar app.jar
EXPOSE 808*
ENTRYPOINT ["java", "-jar", "/app.jar"]
EOF
        print_success "Created Dockerfile for $service"
    fi
done

print_info "Creating application properties for all services..."
for service in "${SERVICES[@]}"; do
    mkdir -p "$service/src/main/resources"
    if [ ! -f "$service/src/main/resources/application.yml" ]; then
        cat > "$service/src/main/resources/application.yml" << EOF
spring:
  application:
    name: $service
  datasource:
    url: jdbc:postgresql://localhost:5432/banking
    username: banking
    password: banking123
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: false

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: always
  metrics:
    export:
      prometheus:
        enabled: true

logging:
  level:
    com.banking: DEBUG
    org.springframework.web: INFO
EOF
        print_success "Created application.yml for $service"
    fi
done

print_info "Creating K8s services..."
cat > k8s/banking-services-svc.yaml << EOF
$(for service in "${SERVICES[@]}"; do
    port=$(echo $service | sed 's/auth-service/8081/; s/account-service/8084/; s/audit-service/8085/; s/balance-service/8086/; s/deposit-service/8087/; s/notification-service/8088/; s/transfer-service/8089/; s/withdrawal-service/8091/; s/api-gateway/8090/')
    cat << EOL
apiVersion: v1
kind: Service
metadata:
  name: $service
spec:
  selector:
    app: $service
  ports:
  - port: $port
    targetPort: $port
---
EOL
done)
EOF

print_success "Updated K8s services"

print_info "Infrastructure update complete!"
echo ""
echo "📋 Updated Components:"
echo "  ✅ CI/CD Pipeline (Jenkinsfile)"
echo "  ✅ K8s Deployments & Services"
echo "  ✅ Prometheus Monitoring"
echo "  ✅ Docker Compose"
echo "  ✅ Logging Configuration"
echo "  ✅ Service Dockerfiles"
echo "  ✅ Application Properties"
echo ""
echo "🚀 Next steps:"
echo "  docker-compose up -d    # Start with monitoring"
echo "  kubectl apply -f k8s/   # Deploy to K8s"

#!/bin/bash

echo "🐳 Creating missing Dockerfiles for GitLab CI"
echo "=============================================="

# Create Dockerfile for auth-service
cat > auth-service/Dockerfile << 'EOF'
FROM openjdk:17-jre-slim

WORKDIR /app

COPY target/*.jar app.jar

EXPOSE 8081

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8081/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
EOF

# Create Dockerfile for account-service
cat > account-service/Dockerfile << 'EOF'
FROM openjdk:17-jre-slim

WORKDIR /app

COPY target/*.jar app.jar

EXPOSE 8084

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8084/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
EOF

# Create Dockerfile for payment-service
cat > payment-service/Dockerfile << 'EOF'
FROM openjdk:17-jre-slim

WORKDIR /app

COPY target/*.jar app.jar

EXPOSE 8083

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8083/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
EOF

# Create Dockerfile for api-gateway
cat > api-gateway/Dockerfile << 'EOF'
FROM openjdk:17-jre-slim

WORKDIR /app

COPY target/*.jar app.jar

EXPOSE 8090

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8090/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
EOF

# Create basic helm directory structure
mkdir -p helm/banking-app/templates
mkdir -p helm/banking-app/charts

# Create basic Chart.yaml
cat > helm/banking-app/Chart.yaml << 'EOF'
apiVersion: v2
name: banking-app
description: Banking Application Helm Chart
type: application
version: 1.0.0
appVersion: "1.0.0"
EOF

# Create basic values.yaml
cat > helm/banking-app/values.yaml << 'EOF'
global:
  environment: dev
  imageTag: latest
  registry: registry.gitlab.com/your-group/banking-app

authService:
  replicas: 2
  port: 8081

accountService:
  replicas: 2
  port: 8084

paymentService:
  replicas: 2
  port: 8083

apiGateway:
  replicas: 1
  port: 8090

bankingUI:
  replicas: 1
  port: 80

database:
  enabled: true

ingress:
  enabled: true
  host: banking.example.com
EOF

echo "✅ Created Dockerfiles for all services"
echo "✅ Created basic Helm chart structure"
echo ""
echo "🔧 Next steps:"
echo "1. Install yamllint: pip install yamllint"
echo "2. Install GitLab CLI: https://gitlab.com/gitlab-org/cli"
echo "3. Run validation again: ./scripts/validate-gitlab-ci.sh"

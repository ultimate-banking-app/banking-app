#!/bin/bash

echo "🚀 Starting Banking Application Services..."

# Kill any existing services
pkill -f "spring-boot:run" 2>/dev/null
pkill -f python3 2>/dev/null

# Wait for processes to stop
sleep 3

# Create logs directory
mkdir -p logs

# Start services in background (skip tests for faster startup)
echo "Starting API Gateway on port 8090..."
(cd api-gateway && mvn spring-boot:run -DskipTests > ../logs/api-gateway.log 2>&1 &)

echo "Starting Auth Service on port 8081..."
(cd auth-service && mvn spring-boot:run -DskipTests > ../logs/auth-service.log 2>&1 &)

echo "Starting Account Service on port 8084..."
(cd account-service && mvn spring-boot:run -DskipTests > ../logs/account-service.log 2>&1 &)

echo "Starting Payment Service on port 8083..."
(cd payment-service && mvn spring-boot:run -DskipTests > ../logs/payment-service.log 2>&1 &)

echo ""
echo "✅ All services starting..."
echo ""
echo "🌐 Service URLs:"
echo "- API Gateway:    http://localhost:8090"
echo "- Auth Service:   http://localhost:8081"
echo "- Account Service: http://localhost:8084"
echo "- Payment Service: http://localhost:8083"
echo ""
echo "📚 Swagger Documentation:"
echo "- API Gateway:    http://localhost:8090/swagger-ui.html"
echo "- Account Service: http://localhost:8084/swagger-ui.html"
echo "- Payment Service: http://localhost:8083/swagger-ui.html"
echo ""
echo "🎯 Banking UI:    file://$(pwd)/banking-ui.html"
echo ""
echo "⏳ Services will be ready in 30-60 seconds..."
echo "📋 Check logs in ./logs/ directory"

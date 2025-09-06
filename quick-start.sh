#!/bin/bash

echo "🚀 Banking Application - Quick Start"
echo "===================================="

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

# Check prerequisites
print_info "Checking prerequisites..."
command -v java >/dev/null 2>&1 || { echo "Java required"; exit 1; }
command -v mvn >/dev/null 2>&1 || { echo "Maven required"; exit 1; }
command -v node >/dev/null 2>&1 || { echo "Node.js required"; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "Docker required"; exit 1; }

print_info "Building services..."
if ! ./build-all.sh; then
    echo "Build failed"
    exit 1
fi

print_info "Starting database..."
docker-compose -f docker-compose-db.yml up -d
sleep 10

print_info "Starting services..."
mkdir -p logs

# Start essential services
cd auth-service && nohup mvn spring-boot:run > ../logs/auth-service.log 2>&1 & echo $! > ../logs/auth-service.pid && cd ..
sleep 5
cd account-service && nohup mvn spring-boot:run > ../logs/account-service.log 2>&1 & echo $! > ../logs/account-service.pid && cd ..
sleep 5
cd audit-service && nohup mvn spring-boot:run > ../logs/audit-service.log 2>&1 & echo $! > ../logs/audit-service.pid && cd ..
sleep 5
cd api-gateway && nohup mvn spring-boot:run > ../logs/api-gateway.log 2>&1 & echo $! > ../logs/api-gateway.pid && cd ..
sleep 5

print_info "Starting UI..."
cd banking-ui
[ ! -d "node_modules" ] && npm install
nohup npm run dev > ../logs/banking-ui.log 2>&1 & echo $! > ../logs/banking-ui.pid
cd ..

sleep 15

echo ""
echo "🎉 Banking Application Started!"
echo "==============================="
echo ""
echo "🌐 Access URLs:"
echo "  Banking UI:      http://localhost:3000"
echo "  API Gateway:     http://localhost:8090"
echo "  Auth Service:    http://localhost:8081"
echo "  Account Service: http://localhost:8084"
echo "  Audit Service:   http://localhost:8085"
echo ""
echo "👤 Demo Credentials:"
echo "  john.doe / password"
echo "  jane.smith / password"
echo "  admin / password"
echo ""
echo "🛑 To stop: ./stop-all-services.sh"

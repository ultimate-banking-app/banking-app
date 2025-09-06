#!/bin/bash

echo "🏦 Starting Complete Banking Application"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
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

# Check prerequisites
print_info "Checking prerequisites..."

# Check Java
if command -v java >/dev/null 2>&1; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
    print_status 0 "Java $JAVA_VERSION found"
else
    print_status 1 "Java not found. Please install Java 17+"
    exit 1
fi

# Check Maven
if command -v mvn >/dev/null 2>&1; then
    MVN_VERSION=$(mvn -version | head -n 1 | cut -d' ' -f3)
    print_status 0 "Maven $MVN_VERSION found"
else
    print_status 1 "Maven not found. Please install Maven 3.8+"
    exit 1
fi

# Check Node.js
if command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node --version)
    print_status 0 "Node.js $NODE_VERSION found"
else
    print_status 1 "Node.js not found. Please install Node.js 18+"
    exit 1
fi

# Check Docker
if command -v docker >/dev/null 2>&1; then
    print_status 0 "Docker found"
else
    print_status 1 "Docker not found. Please install Docker"
    exit 1
fi

echo ""
print_info "Building all services..."

# Build all services
if mvn clean install -DskipTests; then
    print_status 0 "All services built successfully"
else
    print_status 1 "Build failed"
    exit 1
fi

echo ""
print_info "Starting database..."

# Start database
if docker-compose -f docker-compose-db.yml up -d; then
    print_status 0 "Database started"
    sleep 10  # Wait for database to be ready
else
    print_status 1 "Failed to start database"
    exit 1
fi

echo ""
print_info "Starting all services..."

# Define services with their ports and startup order
declare -a SERVICES=(
    "auth-service:8081"
    "audit-service:8085"
    "account-service:8084"
    "balance-service:8086"
    "deposit-service:8087"
    "withdrawal-service:8088"
    "transfer-service:8089"
    "payment-service:8083"
    "notification-service:8091"
    "api-gateway:8090"
)

# Start each service
for service_info in "${SERVICES[@]}"; do
    IFS=':' read -r service port <<< "$service_info"
    
    print_info "Starting $service on port $port..."
    
    cd "$service" || continue
    
    # Start service in background
    nohup mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Dserver.port=$port" > "../logs/$service.log" 2>&1 &
    SERVICE_PID=$!
    
    # Store PID for later cleanup
    echo $SERVICE_PID > "../logs/$service.pid"
    
    cd ..
    
    # Wait a bit for service to start
    sleep 5
    
    # Check if service is running
    if kill -0 $SERVICE_PID 2>/dev/null; then
        print_status 0 "$service started (PID: $SERVICE_PID)"
    else
        print_status 1 "$service failed to start"
    fi
done

echo ""
print_info "Starting Banking UI..."

# Start Banking UI
cd banking-ui || exit 1

if [ ! -d "node_modules" ]; then
    print_info "Installing UI dependencies..."
    npm install
fi

# Start UI in background
nohup npm run dev > ../logs/banking-ui.log 2>&1 &
UI_PID=$!
echo $UI_PID > ../logs/banking-ui.pid

cd ..

sleep 5

if kill -0 $UI_PID 2>/dev/null; then
    print_status 0 "Banking UI started (PID: $UI_PID)"
else
    print_status 1 "Banking UI failed to start"
fi

echo ""
print_info "Waiting for all services to be ready..."
sleep 30

echo ""
echo "🎉 Banking Application Started Successfully!"
echo "==========================================="
echo ""
echo "📊 Service Status:"
echo "=================="

# Check service health
for service_info in "${SERVICES[@]}"; do
    IFS=':' read -r service port <<< "$service_info"
    
    if curl -s "http://localhost:$port/actuator/health" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $service (http://localhost:$port)${NC}"
    else
        echo -e "${RED}❌ $service (http://localhost:$port)${NC}"
    fi
done

echo ""
echo "🌐 Application URLs:"
echo "==================="
echo -e "${BLUE}🎨 Banking UI:        http://localhost:3000${NC}"
echo -e "${BLUE}🚪 API Gateway:       http://localhost:8090${NC}"
echo -e "${BLUE}🔐 Auth Service:      http://localhost:8081${NC}"
echo -e "${BLUE}💰 Account Service:   http://localhost:8084${NC}"
echo -e "${BLUE}💳 Payment Service:   http://localhost:8083${NC}"
echo -e "${BLUE}📋 Audit Service:     http://localhost:8085${NC}"
echo -e "${BLUE}💵 Balance Service:   http://localhost:8086${NC}"
echo -e "${BLUE}📥 Deposit Service:   http://localhost:8087${NC}"
echo -e "${BLUE}📤 Withdrawal Service: http://localhost:8088${NC}"
echo -e "${BLUE}🔄 Transfer Service:  http://localhost:8089${NC}"
echo -e "${BLUE}📧 Notification Service: http://localhost:8091${NC}"

echo ""
echo "👤 Demo Credentials:"
echo "==================="
echo "Username: john.doe    | Password: password"
echo "Username: jane.smith  | Password: password"
echo "Username: bob.wilson  | Password: password"
echo "Username: admin       | Password: password"

echo ""
echo "🔧 Management:"
echo "=============="
echo "To stop all services: ./stop-all-services.sh"
echo "To view logs: tail -f logs/[service-name].log"
echo "To check health: curl http://localhost:[port]/actuator/health"

echo ""
print_info "All services are now running. Access the Banking UI at http://localhost:3000"

#!/bin/bash

echo "🛑 Stopping Banking Application Services"
echo "========================================"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

# Stop services by PID files
SERVICES=("auth-service" "audit-service" "account-service" "balance-service" "deposit-service" "withdrawal-service" "transfer-service" "payment-service" "notification-service" "api-gateway" "banking-ui")

for service in "${SERVICES[@]}"; do
    if [ -f "logs/$service.pid" ]; then
        PID=$(cat "logs/$service.pid")
        if kill -0 $PID 2>/dev/null; then
            kill $PID
            print_status 0 "$service stopped (PID: $PID)"
        else
            print_status 1 "$service was not running"
        fi
        rm -f "logs/$service.pid"
    else
        echo -e "${YELLOW}⚠️  No PID file for $service${NC}"
    fi
done

# Stop database
echo ""
echo "🗄️ Stopping database..."
if docker-compose -f docker-compose-db.yml down; then
    print_status 0 "Database stopped"
else
    print_status 1 "Failed to stop database"
fi

# Kill any remaining Java processes on banking ports
echo ""
echo "🧹 Cleaning up remaining processes..."
for port in 8081 8083 8084 8085 8086 8087 8088 8089 8090 8091; do
    PID=$(lsof -ti:$port 2>/dev/null)
    if [ ! -z "$PID" ]; then
        kill -9 $PID 2>/dev/null
        print_status 0 "Killed process on port $port (PID: $PID)"
    fi
done

# Kill Node.js process on port 3000
PID=$(lsof -ti:3000 2>/dev/null)
if [ ! -z "$PID" ]; then
    kill -9 $PID 2>/dev/null
    print_status 0 "Killed UI process on port 3000 (PID: $PID)"
fi

echo ""
echo "✅ All Banking Application services have been stopped."

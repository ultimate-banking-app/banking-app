# API Testing Guide

## Current Service Ports
- **API Gateway**: 8090
- **Auth Service**: 8081  
- **Account Service**: 8084
- **Payment Service**: 8083

## Quick Test Commands

### 1. Health Check All Services
```bash
# Check if all services are running
for port in 8090 8081 8084 8083; do
  echo "Testing port $port..."
  curl -s http://localhost:$port/actuator/health || echo "Service on port $port not responding"
done
```

### 2. Auth Service Testing (Port 8081)
```bash
# Get all users
curl -s http://localhost:8081/api/auth/users

# Login with sample user
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"john.doe","password":"password"}'

# Validate token
curl -s http://localhost:8081/api/auth/validate \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 3. Account Service Testing (Port 8084)
```bash
# Get all accounts (sample data included)
curl -s http://localhost:8084/api/accounts

# Get specific account
curl -s http://localhost:8084/api/accounts/acc-001

# Get accounts by user
curl -s http://localhost:8084/api/accounts/user/user1

# Create new account
curl -X POST http://localhost:8084/api/accounts/create \
  -d "userId=user3&accountType=CHECKING&currency=USD"
```

### 4. Payment Service Testing (Port 8083)
```bash
# Get all payments (sample data included)
curl -s http://localhost:8083/api/payments

# Get specific payment
curl -s http://localhost:8083/api/payments/pay-001

# Get payments by account
curl -s http://localhost:8083/api/payments/account/acc-001

# Create new payment
curl -X POST http://localhost:8083/api/payments \
  -H "Content-Type: application/json" \
  -d '{
    "fromAccount": "acc-001",
    "toAccount": "acc-002", 
    "amount": 100.00,
    "currency": "USD",
    "type": "TRANSFER"
  }'
```

### 5. API Gateway Testing (Port 8090)
```bash
# Gateway home
curl -s http://localhost:8090/

# Service directory
curl -s http://localhost:8090/api/services
```

## Swagger UI Documentation
- **Account Service**: http://localhost:8084/swagger-ui.html
- **Payment Service**: http://localhost:8083/swagger-ui.html  
- **API Gateway**: http://localhost:8090/swagger-ui.html

## Sample Data Available

### Users (Auth Service)
- john.doe (CUSTOMER)
- jane.smith (CUSTOMER)  
- admin (ADMIN)

### Accounts (Account Service)
- acc-001: user1, CHECKING, $1,500
- acc-002: user1, SAVINGS, $5,000
- acc-003: user2, CHECKING, $750

### Payments (Payment Service)
- pay-001: Transfer acc-001 → acc-002, $250, COMPLETED
- pay-002: Transfer acc-002 → acc-003, $100, PENDING
- pay-003: Withdrawal acc-001, $50, COMPLETED

## Quick Start Testing
```bash
# Start all services
./start-services.sh

# Wait 30 seconds, then test
curl -s http://localhost:8084/api/accounts
curl -s http://localhost:8083/api/payments
curl -s http://localhost:8081/api/auth/users

# Open Banking UI
open banking-ui.html
```

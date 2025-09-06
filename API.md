# 🌐 Banking Application API Documentation

## 🎯 Overview

The Banking Application provides RESTful APIs across multiple microservices, each handling specific business domains. All APIs follow OpenAPI 3.0 specification and include comprehensive Swagger documentation.

## 🔗 Base URLs

### 🌐 Service Endpoints
- **API Gateway**: `http://localhost:8090`
- **Auth Service**: `http://localhost:8081`
- **Account Service**: `http://localhost:8084`
- **Payment Service**: `http://localhost:8083`

### 📚 Swagger Documentation
- **Account Service**: http://localhost:8084/swagger-ui.html
- **Payment Service**: http://localhost:8083/swagger-ui.html
- **API Gateway**: http://localhost:8090/swagger-ui.html

## 🔐 Authentication

### 🎫 JWT Token Authentication
All protected endpoints require a valid JWT token in the Authorization header:

```http
Authorization: Bearer <jwt-token>
```

### 🔑 Login Endpoint
```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "john.doe",
  "password": "password"
}
```

**Response:**
```json
{
  "message": "Login successful",
  "user": {
    "id": "user1",
    "username": "john.doe",
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@example.com",
    "role": "CUSTOMER",
    "status": "ACTIVE"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

## 🔐 Auth Service API

### 👤 User Management

#### Get All Users
```http
GET /api/auth/users
Authorization: Bearer <token>
```

**Response:**
```json
[
  {
    "id": "user1",
    "username": "john.doe",
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@example.com",
    "role": "CUSTOMER",
    "status": "ACTIVE",
    "createdAt": "2025-01-01T10:00:00Z",
    "updatedAt": "2025-01-01T10:00:00Z"
  }
]
```

#### Get User by ID
```http
GET /api/auth/users/{userId}
Authorization: Bearer <token>
```

#### Create User
```http
POST /api/auth/users
Authorization: Bearer <token>
Content-Type: application/json

{
  "username": "new.user",
  "password": "securePassword",
  "firstName": "New",
  "lastName": "User",
  "email": "new.user@example.com",
  "role": "CUSTOMER"
}
```

#### Update User
```http
PUT /api/auth/users/{userId}
Authorization: Bearer <token>
Content-Type: application/json

{
  "firstName": "Updated",
  "lastName": "Name",
  "email": "updated.email@example.com"
}
```

#### Delete User
```http
DELETE /api/auth/users/{userId}
Authorization: Bearer <token>
```

### 🔒 Authentication Endpoints

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "john.doe",
  "password": "password"
}
```

#### Logout
```http
POST /api/auth/logout
Authorization: Bearer <token>
```

#### Refresh Token
```http
POST /api/auth/refresh
Authorization: Bearer <token>
```

#### Validate Token
```http
GET /api/auth/validate
Authorization: Bearer <token>
```

## 💰 Account Service API

### 🏦 Account Management

#### Get All Accounts
```http
GET /api/accounts
Authorization: Bearer <token>
```

**Response:**
```json
[
  {
    "id": "acc-001",
    "userId": "user1",
    "accountNumber": "1234567890",
    "accountType": "CHECKING",
    "balance": 1500.00,
    "currency": "USD",
    "status": "ACTIVE",
    "createdAt": "2025-01-01T10:00:00Z",
    "updatedAt": "2025-01-01T10:00:00Z"
  }
]
```

#### Get Account by ID
```http
GET /api/accounts/{accountId}
Authorization: Bearer <token>
```

#### Get Accounts by User
```http
GET /api/accounts/user/{userId}
Authorization: Bearer <token>
```

#### Create Account
```http
POST /api/accounts/create
Authorization: Bearer <token>
Content-Type: application/json

{
  "userId": "user1",
  "accountType": "SAVINGS",
  "initialBalance": 1000.00,
  "currency": "USD"
}
```

#### Update Account
```http
PUT /api/accounts/{accountId}
Authorization: Bearer <token>
Content-Type: application/json

{
  "status": "ACTIVE"
}
```

#### Close Account
```http
DELETE /api/accounts/{accountId}
Authorization: Bearer <token>
```

### 💸 Balance Operations

#### Get Account Balance
```http
GET /api/accounts/{accountId}/balance
Authorization: Bearer <token>
```

**Response:**
```json
{
  "accountId": "acc-001",
  "balance": 1500.00,
  "currency": "USD",
  "lastUpdated": "2025-01-01T10:00:00Z"
}
```

#### Update Balance
```http
PUT /api/accounts/{accountId}/balance
Authorization: Bearer <token>
Content-Type: application/json

{
  "amount": 100.00,
  "operation": "CREDIT",
  "description": "Deposit"
}
```

### 📊 Transaction History

#### Get Account Transactions
```http
GET /api/accounts/{accountId}/transactions?page=0&size=10&sort=createdAt,desc
Authorization: Bearer <token>
```

**Response:**
```json
{
  "content": [
    {
      "id": "txn-001",
      "accountId": "acc-001",
      "amount": 250.00,
      "type": "DEBIT",
      "description": "Transfer to savings",
      "balance": 1250.00,
      "createdAt": "2025-01-01T10:00:00Z"
    }
  ],
  "pageable": {
    "page": 0,
    "size": 10,
    "totalElements": 1,
    "totalPages": 1
  }
}
```

## 💳 Payment Service API

### 💰 Payment Management

#### Get All Payments
```http
GET /api/payments
Authorization: Bearer <token>
```

**Response:**
```json
[
  {
    "id": "pay-001",
    "fromAccount": "acc-001",
    "toAccount": "acc-002",
    "amount": 250.00,
    "currency": "USD",
    "type": "TRANSFER",
    "status": "COMPLETED",
    "description": "Transfer to savings",
    "createdAt": "2025-01-01T10:00:00Z",
    "updatedAt": "2025-01-01T10:00:00Z"
  }
]
```

#### Get Payment by ID
```http
GET /api/payments/{paymentId}
Authorization: Bearer <token>
```

#### Get Payments by Account
```http
GET /api/payments/account/{accountId}?page=0&size=10
Authorization: Bearer <token>
```

#### Create Payment
```http
POST /api/payments
Authorization: Bearer <token>
Content-Type: application/json

{
  "fromAccount": "acc-001",
  "toAccount": "acc-002",
  "amount": 100.00,
  "currency": "USD",
  "type": "TRANSFER",
  "description": "Monthly transfer"
}
```

**Response:**
```json
{
  "id": "pay-002",
  "fromAccount": "acc-001",
  "toAccount": "acc-002",
  "amount": 100.00,
  "currency": "USD",
  "type": "TRANSFER",
  "status": "PENDING",
  "description": "Monthly transfer",
  "createdAt": "2025-01-01T10:00:00Z"
}
```

#### Update Payment Status
```http
PUT /api/payments/{paymentId}/status
Authorization: Bearer <token>
Content-Type: application/json

{
  "status": "COMPLETED"
}
```

#### Cancel Payment
```http
DELETE /api/payments/{paymentId}
Authorization: Bearer <token>
```

### 🔄 Transfer Operations

#### Internal Transfer
```http
POST /api/payments/transfer
Authorization: Bearer <token>
Content-Type: application/json

{
  "fromAccount": "acc-001",
  "toAccount": "acc-002",
  "amount": 500.00,
  "description": "Internal transfer"
}
```

#### External Transfer
```http
POST /api/payments/external-transfer
Authorization: Bearer <token>
Content-Type: application/json

{
  "fromAccount": "acc-001",
  "toAccountNumber": "9876543210",
  "toBankCode": "BANK001",
  "amount": 200.00,
  "description": "External transfer"
}
```

### 📊 Payment Analytics

#### Get Payment Statistics
```http
GET /api/payments/statistics?fromDate=2025-01-01&toDate=2025-01-31
Authorization: Bearer <token>
```

**Response:**
```json
{
  "totalPayments": 150,
  "totalAmount": 75000.00,
  "averageAmount": 500.00,
  "paymentsByType": {
    "TRANSFER": 120,
    "WITHDRAWAL": 20,
    "DEPOSIT": 10
  },
  "paymentsByStatus": {
    "COMPLETED": 140,
    "PENDING": 8,
    "FAILED": 2
  }
}
```

## 🌐 API Gateway Routes

### 🔄 Route Configuration
The API Gateway routes requests to appropriate microservices:

```yaml
Routes:
  - /api/auth/** → Auth Service (8081)
  - /api/accounts/** → Account Service (8084)
  - /api/payments/** → Payment Service (8083)
  - /actuator/** → All Services (Health checks)
```

### 🔒 Gateway Features
- **Authentication**: JWT token validation
- **Rate Limiting**: Request throttling
- **Load Balancing**: Request distribution
- **Circuit Breaker**: Fault tolerance
- **Request/Response Transformation**: Data mapping

## 🏥 Health Check Endpoints

### 📊 Service Health
```http
GET /actuator/health
```

**Response:**
```json
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP",
      "details": {
        "database": "PostgreSQL",
        "validationQuery": "isValid()"
      }
    },
    "diskSpace": {
      "status": "UP",
      "details": {
        "total": 245107195904,
        "free": 32324390912,
        "threshold": 10485760
      }
    },
    "ping": {
      "status": "UP"
    }
  }
}
```

### 📈 Metrics Endpoint
```http
GET /actuator/metrics
```

### 📋 Info Endpoint
```http
GET /actuator/info
```

## 🔧 Error Handling

### 📋 Standard Error Response
```json
{
  "timestamp": "2025-01-01T10:00:00Z",
  "status": 400,
  "error": "Bad Request",
  "message": "Validation failed",
  "path": "/api/accounts",
  "details": [
    {
      "field": "amount",
      "message": "Amount must be positive"
    }
  ]
}
```

### 🚨 HTTP Status Codes
- **200 OK**: Successful request
- **201 Created**: Resource created successfully
- **400 Bad Request**: Invalid request data
- **401 Unauthorized**: Authentication required
- **403 Forbidden**: Access denied
- **404 Not Found**: Resource not found
- **409 Conflict**: Resource conflict
- **500 Internal Server Error**: Server error

## 📊 Rate Limiting

### 🔒 Rate Limit Headers
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640995200
```

### 🚫 Rate Limit Exceeded
```json
{
  "timestamp": "2025-01-01T10:00:00Z",
  "status": 429,
  "error": "Too Many Requests",
  "message": "Rate limit exceeded. Try again later.",
  "retryAfter": 60
}
```

## 🔍 API Testing

### 🧪 Postman Collection
```bash
# Import Postman collection
curl -o banking-api.postman_collection.json \
  https://raw.githubusercontent.com/your-org/banking-app/main/docs/postman/banking-api.postman_collection.json
```

### 🔧 cURL Examples

#### Login and Get Token
```bash
# Login
TOKEN=$(curl -s -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"john.doe","password":"password"}' | \
  jq -r '.token')

# Use token for authenticated requests
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8084/api/accounts
```

#### Create Account
```bash
curl -X POST http://localhost:8084/api/accounts/create \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user1",
    "accountType": "SAVINGS",
    "initialBalance": 1000.00,
    "currency": "USD"
  }'
```

#### Make Payment
```bash
curl -X POST http://localhost:8083/api/payments \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fromAccount": "acc-001",
    "toAccount": "acc-002",
    "amount": 100.00,
    "currency": "USD",
    "type": "TRANSFER",
    "description": "Test payment"
  }'
```

## 📚 API Versioning

### 🔄 Version Strategy
- **URL Versioning**: `/api/v1/accounts`, `/api/v2/accounts`
- **Header Versioning**: `Accept: application/vnd.banking.v1+json`
- **Backward Compatibility**: Maintain previous versions

### 📋 Version Information
```http
GET /api/version
```

**Response:**
```json
{
  "version": "1.0.0",
  "buildTime": "2025-01-01T10:00:00Z",
  "gitCommit": "abc123def456",
  "supportedVersions": ["v1", "v2"]
}
```

---

**🌐 This API documentation provides comprehensive information about all available endpoints, authentication methods, request/response formats, and testing procedures for the Banking Application microservices.**

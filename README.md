# Banking Application - Java Microservices

A comprehensive banking application built with Spring Boot microservices architecture.

## Services Overview

### Core Services
- **api-gateway** (Port 8080): Routes requests to appropriate services
- **auth-service** (Port 8081): User authentication and JWT token management
- **account-service** (Port 8082): Account creation and management
- **payment-service** (Port 8083): Payment processing
- **balance-service** (Port 8084): Balance inquiries and statements
- **transfer-service** (Port 8085): Money transfers (domestic/international)
- **deposit-service** (Port 8086): Deposit processing
- **withdrawal-service** (Port 8087): Withdrawal processing
- **notification-service** (Port 8088): SMS/Email notifications
- **audit-service** (Port 8089): Transaction logging and compliance

### Infrastructure
- **PostgreSQL**: Primary database
- **Redis**: Caching and session management

## Technology Stack

- **Java 17**
- **Spring Boot 3.2.0**
- **Spring Cloud Gateway**
- **Spring Security**
- **Spring Data JPA**
- **PostgreSQL**
- **Redis**
- **Maven**
- **Docker**

## Quick Start

### Prerequisites
- Java 17+
- Maven 3.6+
- Docker & Docker Compose

### Build and Run

1. **Clone and build**:
```bash
git clone <repository-url>
cd banking-app
mvn clean install
```

2. **Start with Docker**:
```bash
docker-compose up --build
```

3. **Access the application**:
- API Gateway: http://localhost:8080
- Individual services: http://localhost:808X (where X is service number)

## API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/verify` - Token verification

### Account Management
- `POST /api/accounts/create` - Create new account
- `GET /api/accounts/{id}` - Get account details
- `GET /api/accounts/user/{userId}` - Get user accounts

### Transactions
- `POST /api/payments/process` - Process payment
- `POST /api/transfers/domestic` - Domestic transfer
- `POST /api/transfers/international` - International transfer
- `POST /api/deposits/process` - Process deposit
- `POST /api/withdrawals/process` - Process withdrawal

### Balance & Reporting
- `GET /api/balance/{accountId}` - Get account balance
- `GET /api/audit/transactions/{accountId}` - Transaction history

## Development

### Running Individual Services
Each service can be run independently:
```bash
cd auth-service
mvn spring-boot:run
```

### Database Schema
Services use JPA entities with automatic schema generation. Check individual service configurations for database setup.

### Testing
```bash
mvn test
```

## Architecture

```
┌─────────────────┐
│   API Gateway   │ :8080
│  (Spring Cloud) │
└─────────┬───────┘
          │
    ┌─────┴─────┐
    │           │
┌───▼───┐   ┌───▼────┐
│ Auth  │   │ Core   │
│Service│   │Services│
│ :8081 │   │:8082-89│
└───┬───┘   └───┬────┘
    │           │
    └─────┬─────┘
          │
    ┌─────▼─────┐
    │PostgreSQL │
    │   Redis   │
    └───────────┘
```

## Business Features

- **Multi-currency support**
- **Real-time balance updates**
- **Transaction audit trail**
- **International transfers**
- **Account management**
- **Security & compliance**
- **Notification system**

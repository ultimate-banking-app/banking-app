# Database Integration - PostgreSQL

## 🗄️ Database Architecture

### **PostgreSQL Database Setup**
- **Database**: banking_db
- **User**: banking_user
- **Password**: banking_pass
- **Port**: 5432

### **Database Schema**

#### **Users Table**
```sql
CREATE TABLE users (
    id VARCHAR(50) PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'CUSTOMER',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### **Accounts Table**
```sql
CREATE TABLE accounts (
    id VARCHAR(50) PRIMARY KEY,
    account_number VARCHAR(50) UNIQUE NOT NULL,
    user_id VARCHAR(50) NOT NULL,
    account_type VARCHAR(20) NOT NULL,
    balance DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

#### **Payments Table**
```sql
CREATE TABLE payments (
    id VARCHAR(50) PRIMARY KEY,
    from_account VARCHAR(50),
    to_account VARCHAR(50),
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    type VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (from_account) REFERENCES accounts(account_number),
    FOREIGN KEY (to_account) REFERENCES accounts(account_number)
);
```

## 🚀 Quick Start

### **1. Start Database**
```bash
# Start PostgreSQL container
docker-compose -f docker-compose-db.yml up -d

# Check database status
docker ps | grep postgres
```

### **2. Start Services**
```bash
# Start all services with database integration
./start-services.sh

# Services will connect to PostgreSQL automatically
```

### **3. Test Database Integration**
```bash
# Test users from database
curl http://localhost:8081/api/auth/users

# Test accounts from database
curl http://localhost:8084/api/accounts

# Test payments from database
curl http://localhost:8083/api/payments
```

## 📊 Sample Data

### **Users**
- john.doe (CUSTOMER)
- jane.smith (CUSTOMER)
- admin (ADMIN)

### **Accounts**
- acc-001: user1, CHECKING, $1,500
- acc-002: user1, SAVINGS, $5,000
- acc-003: user2, CHECKING, $750

### **Payments**
- pay-001: Transfer acc-001 → acc-002, $250, COMPLETED
- pay-002: Transfer acc-002 → acc-003, $100, PENDING
- pay-003: Withdrawal acc-001, $50, COMPLETED

## 🔧 Service Configuration

### **Auth Service (8081)**
- **Entity**: User
- **Repository**: UserRepository
- **Endpoints**: /api/auth/login, /api/auth/users

### **Account Service (8084)**
- **Entity**: Account
- **Repository**: AccountRepository
- **Endpoints**: /api/accounts, /api/accounts/{id}

### **Payment Service (8083)**
- **Entity**: Payment
- **Repository**: PaymentRepository
- **Endpoints**: /api/payments, /api/payments/{id}

## 🌐 UI Integration

The Vue.js UI automatically connects to database-backed services:
- **Login**: Authenticates against PostgreSQL users
- **Accounts**: Displays real account data from database
- **Payments**: Shows actual payment history
- **Real-time Updates**: All CRUD operations persist to database

## 📋 Database Management

### **Connect to Database**
```bash
# Using Docker exec
docker exec -it banking-postgres psql -U banking_user -d banking_db

# View tables
\dt

# Query users
SELECT * FROM users;

# Query accounts
SELECT * FROM accounts;

# Query payments
SELECT * FROM payments;
```

### **Backup & Restore**
```bash
# Backup
docker exec banking-postgres pg_dump -U banking_user banking_db > backup.sql

# Restore
docker exec -i banking-postgres psql -U banking_user banking_db < backup.sql
```

## ✅ **Database Integration Complete!**

- **PostgreSQL**: Production-ready database
- **JPA Entities**: Proper ORM mapping
- **Sample Data**: Pre-loaded for testing
- **Full Integration**: UI ↔ Services ↔ Database
- **Persistent Storage**: All data survives restarts

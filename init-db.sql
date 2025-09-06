-- Banking Database Schema

-- Users table
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

-- Accounts table
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

-- Payments table
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

-- Insert sample users
INSERT INTO users (id, username, password, first_name, last_name, email, role, status) VALUES
('user1', 'john.doe', 'password', 'John', 'Doe', 'john.doe@example.com', 'CUSTOMER', 'ACTIVE'),
('user2', 'jane.smith', 'password', 'Jane', 'Smith', 'jane.smith@example.com', 'CUSTOMER', 'ACTIVE'),
('admin', 'admin', 'password', 'Admin', 'User', 'admin@example.com', 'ADMIN', 'ACTIVE');

-- Insert sample accounts
INSERT INTO accounts (id, account_number, user_id, account_type, balance, currency, status) VALUES
('acc-001', 'acc-001', 'user1', 'CHECKING', 1500.00, 'USD', 'ACTIVE'),
('acc-002', 'acc-002', 'user1', 'SAVINGS', 5000.00, 'USD', 'ACTIVE'),
('acc-003', 'acc-003', 'user2', 'CHECKING', 750.00, 'USD', 'ACTIVE');

-- Insert sample payments
INSERT INTO payments (id, from_account, to_account, amount, currency, type, status, description) VALUES
('pay-001', 'acc-001', 'acc-002', 250.00, 'USD', 'TRANSFER', 'COMPLETED', 'Transfer to savings'),
('pay-002', 'acc-002', 'acc-003', 100.00, 'USD', 'TRANSFER', 'PENDING', 'Transfer to Jane'),
('pay-003', 'acc-001', NULL, 50.00, 'USD', 'WITHDRAWAL', 'COMPLETED', 'ATM withdrawal');

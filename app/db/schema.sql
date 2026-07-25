-- ==============================================================================
-- Enterprise Banking Platform - Initial Database Schema
-- Database Engine: PostgreSQL / MySQL
-- ==============================================================================

CREATE TABLE IF NOT EXISTS customers (
    customer_id VARCHAR(64) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(30),
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS accounts (
    account_number VARCHAR(32) PRIMARY KEY,
    customer_id VARCHAR(64) REFERENCES customers(customer_id),
    account_type VARCHAR(30) CHECK (account_type IN ('CHECKING', 'SAVINGS', 'INVESTMENT')),
    balance NUMERIC(15, 2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'USD',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS audit_logs (
    log_id BIGSERIAL PRIMARY KEY,
    account_number VARCHAR(32),
    action VARCHAR(50) NOT NULL,
    amount NUMERIC(15, 2),
    performed_by VARCHAR(100),
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

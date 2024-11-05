-- Start transaction
BEGIN;

-- Drop existing tables
DROP TABLE IF EXISTS payment CASCADE;
DROP TABLE IF EXISTS bill CASCADE;
DROP TABLE IF EXISTS call_record CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS bank_account CASCADE;
DROP TABLE IF EXISTS phone_plan CASCADE;

-- Create sequences for IDs
CREATE SEQUENCE IF NOT EXISTS phone_plan_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bank_account_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS customer_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS call_record_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bill_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS payment_id_seq START WITH 1 INCREMENT BY 1;

-- Phone Plan Table
CREATE TABLE phone_plan (
    phone_plan_id INT PRIMARY KEY,
    plan_type VARCHAR(50) NOT NULL,
    monthly_charge DECIMAL(10, 2) NOT NULL,
    data_limit INT NOT NULL,
    talk_limit INT NOT NULL
);

-- Bank Account Table
CREATE TABLE bank_account (
    bank_account_id INT PRIMARY KEY,
    bank_name VARCHAR(255) NOT NULL,
    account_number VARCHAR(50) NOT NULL,
    routing_number VARCHAR(50) NOT NULL,
    balance DECIMAL(10,2) NOT NULL
);

-- Customer Table
CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(12) NOT NULL,
    email VARCHAR(255),
    address VARCHAR(255),
    phone_plan_id INT NOT NULL,
    bank_account_id INT NOT NULL,
    FOREIGN KEY (phone_plan_id) REFERENCES phone_plan(phone_plan_id),
    FOREIGN KEY (bank_account_id) REFERENCES bank_account(bank_account_id)
);

-- Call Record Table
CREATE TABLE call_record (
    call_id INT PRIMARY KEY,
    call_time TIMESTAMP NOT NULL,
    call_duration INT NOT NULL,
    call_data_usage INT NOT NULL,
    cost DECIMAL(10, 2) NOT NULL,
    customer_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

-- Bill Table
CREATE TABLE bill (
    bill_id INT PRIMARY KEY,
    bill_date DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    due_date DATE NOT NULL,
    bill_status VARCHAR(20) NOT NULL,
    customer_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

-- Payment Table
CREATE TABLE payment (
    payment_id INT PRIMARY KEY,
    payment_method VARCHAR(50) NOT NULL,
    payment_type VARCHAR(50) NOT NULL,
    payment_date DATE NOT NULL,
    payment_amount DECIMAL(10,2) NOT NULL,
    bill_id INT NOT NULL,
    bank_account_id INT NOT NULL,
    FOREIGN KEY (bill_id) REFERENCES bill(bill_id),
    FOREIGN KEY (bank_account_id) REFERENCES bank_account(bank_account_id)
);

-- Commit transaction
COMMIT;

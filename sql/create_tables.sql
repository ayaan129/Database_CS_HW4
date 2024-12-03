-- Start transaction
BEGIN;

-- Drop existing tables
DROP TABLE IF EXISTS payment CASCADE;
DROP TABLE IF EXISTS bill CASCADE;
DROP TABLE IF EXISTS call_record CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS bank_account CASCADE;
DROP TABLE IF EXISTS phone_plan CASCADE;
DROP TABLE IF EXISTS address CASCADE;
DROP TABLE IF EXISTS customer_service CASCADE;
DROP TABLE IF EXISTS phone_warranty CASCADE;
DROP TABLE IF EXISTS service_range CASCADE;

-- Create sequences for IDs
CREATE SEQUENCE IF NOT EXISTS phone_plan_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bank_account_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS customer_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS bill_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS payment_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS address_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS customer_service_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS phone_warranty_id_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE IF NOT EXISTS service_range_id_seq START WITH 1 INCREMENT BY 1;

-- Phone Plan Table
CREATE TABLE phone_plan (
    phone_plan_id INT PRIMARY KEY,
    plan_type VARCHAR(50) NOT NULL,
    monthly_charge DECIMAL(10, 2) NOT NULL,
    data_limit INT NOT NULL,
    talk_limit INT NULL
);

--Bank Account Table
CREATE TABLE bank_account (
    bank_account_id INT PRIMARY KEY,
    account_holder_name VARCHAR(255) NOT NULL,
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
    phone_plan_id INT NOT NULL,
    bank_account_id INT NOT NULL,
    FOREIGN KEY (phone_plan_id) REFERENCES phone_plan(phone_plan_id),
    FOREIGN KEY (bank_account_id) REFERENCES bank_account(bank_account_id)
);

--Call Record Table
CREATE TABLE call_record (
    call_start_time DATETIME NOT NULL,
    call_end_time DATETIME NOT NULL,
    call_duration INT NOT NULL,
    data_usage INT NOT NULL,
    cost DECIMAL(10, 2) NOT NULL,
    customer_id INT NOT NULL,
    PRIMARY KEY (customer_id, call_start_time),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

--Phone Bill Table
CREATE TABLE bill (
    bill_id INT PRIMARY KEY,    
    bill_date DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    due_date DATE NOT NULL,
    bill_status VARCHAR(20) NOT NULL,
    customer_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

--Payment Table
CREATE TABLE payment (
    payment_method VARCHAR(50) NOT NULL,
    payment_type VARCHAR(50) NOT NULL,
    payment_date DATE NOT NULL,
    payment_amount DECIMAL(10,2) NOT NULL,
    bill_id INT NOT NULL,
    bank_account_id INT NOT NULL,
    PRIMARY KEY (payment_date, bill_id, bank_account_id),
    FOREIGN KEY (bill_id) REFERENCES bill(bill_id),
    FOREIGN KEY (bank_account_id) REFERENCES bank_account(bank_account_id)
);

-- Address Table
CREATE TABLE address (
    address_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    street_address VARCHAR(255) NOT NULL,
    city VARCHAR(255) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zip_code VARCHAR(20) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

-- Customer Service Table
CREATE TABLE customer_service (
    service_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    service_date DATE NOT NULL,
    issue_description TEXT NOT NULL,
    resolution_description TEXT,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

-- Phone Warranty Table
CREATE TABLE phone_warranty (
    warranty_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    warranty_start_date DATE NOT NULL,
    warranty_end_date DATE NOT NULL,
    warranty_status VARCHAR(50) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

-- Service Range Table
CREATE TABLE service_range (
    range_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    region_name VARCHAR(255) NOT NULL,
    coverage_area VARCHAR(255) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

-- Relationship from customer to phone plan: Many-to-One
-- Each customer can have only one phone plan, but multiple customers can have the same phone plan this is reinforced by the phone_plan_id foreign key in the customer table.

-- Relationship from customer to bank account: One-to-Many
-- Each customer can have many linked bank accounts, but each bank account belongs to one customer this is reinforced by the bank_account_id foreign key in the customer table.

-- Relationship from customer to call record: One-to-Many
-- Each customer can have multiple call records, but each call record belongs to one customer this is reinforced by the customer_id foreign key in the call_record table.

-- Relationship from customer to bill: One-to-Many
-- Each customer can have multiple bills, but each bill belongs to one customer this is reinforced bu the customer_id foreign key in the bill table.

-- Relationship from payment to bill: Many-to-One
-- Each payment is associated with one bill, and each bill can have multiple payment this is reinforced by the bill_id foreign key in the payment table.

-- Relationship from payment to bank account: Many-to-One
-- Each payment is made from one bank account, but multiple payments can be made from the same bank account this is reinforced by the bank_account_id foreign key in the payment table.

-- Relationship from customer to address: One-to-Many
-- Each customer can have many addresses, but each address belongs to one customer this is reinforced by the customer_id foreign key in the address table

-- Relationship from customer to customer_service: One-to-Many
-- Each customer can have many customer service occasions, but each customer_service occasion belongs to one customer this is reinforced by the customer_id foreign key in the customer_service table.

-- Relationship from customer to phone_warranty: One-to-Many
-- Each customer can have many phone warranties, but each warranty belongs to one customer this is reinforced by the customer_id foreign key in the phone_warrany table.

-- Relationship from customer to service_range: One-to-Many
-- Each customer can have many service ranges, but each service range belongs to one customer this is reinforced by the customer_id foreign key in the service_range table.

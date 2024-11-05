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
    talk_time INT NOT NULL
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
    call_time TIMESTAMP NOT NULL, -- Changed from DATETIME to TIMESTAMP
    call_duration INT NOT NULL,
    call_data INT NOT NULL,
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

-- Insert data into phone_plan
INSERT INTO phone_plan (phone_plan_id, plan_type, monthly_charge, data_limit, talk_time) VALUES
(1, 'Basic',    19.99, 1000,  500),
(2, 'Standard', 29.99, 3000, 1500),
(3, 'Premium',  49.99, 7000, 3500),
(4, 'Unlimited',69.99, 10000, 9999),
(5, 'Family',   39.99, 5000, 2500),
(6, 'Student',  24.99, 2000, 1000),
(7, 'Business',59.99, 8000, 4000),
(8, 'Eco',      14.99, 500,  250),
(9, 'Gaming',   54.99, 9000, 4500),
(10,'Traveler',64.99, 8500, 4250);

-- Insert data into bank_account
INSERT INTO bank_account (bank_account_id, bank_name, account_number, routing_number, balance) VALUES
(1,  'Bank of America', '1234567890', '111000025', 2500.75),
(2,  'Chase Bank',      '2345678901', '021000021', 4800.50),
(3,  'Wells Fargo',     '3456789012', '121000248', 3200.00),
(4,  'Citibank',        '4567890123', '021000089', 1500.25),
(5,  'Capital One',     '5678901234', '051000017', 6100.40),
(6,  'US Bank',         '6789012345', '081000210', 4300.60),
(7,  'PNC Bank',        '7890123456', '031000053', 2750.30),
(8,  'TD Bank',         '8901234567', '031100649', 3900.90),
(9,  'BB&T',            '9012345678', '053000196', 5200.80),
(10, 'SunTrust',        '0123456789', '061000104', 3600.10);

-- Insert data into customer
INSERT INTO customer (customer_id, name, phone_number, email, address, phone_plan_id, bank_account_id) VALUES
(1, 'Alice Johnson',    '555-0101', 'alice.johnson@example.com', '123 Maple St, Springfield', 1,  1),
(2, 'Bob Smith',        '555-0102', 'bob.smith@example.com',     '456 Oak St, Springfield',   2,  2),
(3, 'Carol Williams',   '555-0103', 'carol.williams@example.com','789 Pine St, Springfield', 3,  3),
(4, 'David Brown',      '555-0104', 'david.brown@example.com',   '321 Elm St, Springfield', 4,  4),
(5, 'Eva Davis',        '555-0105', 'eva.davis@example.com',     '654 Cedar St, Springfield',5,  5),
(6, 'Frank Miller',     '555-0106', 'frank.miller@example.com',  '987 Birch St, Springfield',6,  6),
(7, 'Grace Wilson',     '555-0107', 'grace.wilson@example.com',  '147 Spruce St, Springfield',7,  7),
(8, 'Henry Moore',      '555-0108', 'henry.moore@example.com',   '258 Willow St, Springfield',8,  8),
(9, 'Ivy Taylor',       '555-0109', 'ivy.taylor@example.com',    '369 Aspen St, Springfield',9,  9),
(10,'Jack Anderson',    '555-0110', 'jack.anderson@example.com', '159 Walnut St, Springfield',10,10);

-- Insert data into call_record
INSERT INTO call_record (call_id, call_time, call_duration, call_data, cost, customer_id) VALUES
(1,  '2024-04-01 08:30:00',  300, 50, 2.50, 1),
(2,  '2024-04-02 09:15:00',  200, 30, 1.75, 2),
(3,  '2024-04-03 10:45:00',  600, 80, 4.00, 3),
(4,  '2024-04-04 11:00:00',  150, 20, 1.25, 4),
(5,  '2024-04-05 12:30:00',  400, 60, 3.00, 5),
(6,  '2024-04-06 13:45:00',  250, 35, 2.20, 6),
(7,  '2024-04-07 14:20:00',  500, 75, 3.75, 7),
(8,  '2024-04-08 15:10:00',  350, 55, 2.90, 8),
(9,  '2024-04-09 16:50:00',  450, 65, 3.50, 9),
(10, '2024-04-10 17:30:00',  100, 15, 0.80,10);

-- Insert data into bill
INSERT INTO bill (bill_id, bill_date, total_amount, due_date, bill_status, customer_id) VALUES
(1,  '2024-04-01',  59.99, '2024-04-15', 'Paid',     1),
(2,  '2024-04-02',  89.99, '2024-04-16', 'Unpaid',   2),
(3,  '2024-04-03', 119.99, '2024-04-17', 'Paid',     3),
(4,  '2024-04-04', 149.99, '2024-04-18', 'Unpaid',   4),
(5,  '2024-04-05', 199.99, '2024-04-19', 'Paid',     5),
(6,  '2024-04-06', 249.99, '2024-04-20', 'Unpaid',   6),
(7,  '2024-04-07', 299.99, '2024-04-21', 'Paid',     7),
(8,  '2024-04-08', 349.99, '2024-04-22', 'Unpaid',   8),
(9,  '2024-04-09', 399.99, '2024-04-23', 'Paid',     9),
(10, '2024-04-10', 449.99, '2024-04-24', 'Unpaid',  10);

-- Insert data into payment
INSERT INTO payment (payment_id, payment_method, payment_type, payment_date, payment_amount, bill_id, bank_account_id) VALUES
(1,  'Credit Card', 'Online',    '2024-04-14', 59.99, 1, 1),
(2,  'Debit Card',  'In-Person','2024-04-17', 89.99, 2, 2),
(3,  'Bank Transfer','Online',   '2024-04-16',119.99, 3, 3),
(4,  'Credit Card', 'Online',    '2024-04-18',149.99, 4, 4),
(5,  'Debit Card',  'In-Person','2024-04-19',199.99, 5, 5),
(6,  'Bank Transfer','Online',   '2024-04-20',249.99, 6, 6),
(7,  'Credit Card', 'Online',    '2024-04-21',299.99, 7, 7),
(8,  'Debit Card',  'In-Person','2024-04-22',349.99, 8, 8),
(9,  'Bank Transfer','Online',   '2024-04-23',399.99, 9, 9),
(10, 'Credit Card', 'Online',    '2024-04-24',449.99,10,10);

-- Commit transaction
COMMIT;

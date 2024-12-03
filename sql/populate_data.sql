-- Start transaction and reset tables
BEGIN;

-- Clear existing data
TRUNCATE phone_plan, bank_account, customer, call_record, bill, payment CASCADE;

-- Reset sequences
ALTER SEQUENCE phone_plan_id_seq RESTART WITH 1;
ALTER SEQUENCE bank_account_id_seq RESTART WITH 1;
ALTER SEQUENCE customer_id_seq RESTART WITH 1;
ALTER SEQUENCE bill_id_seq RESTART WITH 1;
ALTER SEQUENCE payment_id_seq RESTART WITH 1;

-- Insert data into phone_plan first (since it's referenced by customer)
INSERT INTO phone_plan (plan_type, monthly_charge, data_limit, talk_limit) VALUES
('Basic',    19.99, 1000,  500),
('Standard', 29.99, 3000, 1500),
('Premium',  49.99, 7000, 3500),
('Unlimited',69.99, 10000, 999999),
('Family',   39.99, 5000, 2500),
('Student',  24.99, 2000, 1000),
('Business',59.99, 8000, 4000),
('Eco',      14.99, 500,  250),
('Gaming',   54.99, 9000, 4500),
('Traveler',64.99, 8500, 4250);

-- Insert data into bank_account (since it's referenced by customer)
INSERT INTO bank_account (account_holder_name, bank_name, account_number, routing_number, balance) VALUES
('Alice Johnson', 'Bank of America', '1234567890', '111000025', 2500.75),
('Bob Smith', 'Chase Bank',      '2345678901', '021000021', 4800.50),
('Carol Williams', 'Wells Fargo',     '3456789012', '121000248', 3200.00),
('David Brown', 'Citibank',        '4567890123', '021000089', 1500.25),
('Eva Davis', 'Capital One',     '5678901234', '051000017', 6100.40),
('Frank Miller', 'US Bank',         '6789012345', '081000210', 4300.60),
('Grace Wilson', 'PNC Bank',        '7890123456', '031000053', 2750.30),
('Henry Moore', 'TD Bank',         '8901234567', '031100649', 3900.90),
('Ivy Taylor', 'BB&T',            '9012345678', '053000196', 5200.80),
('Jack Anderson', 'SunTrust',        '0123456789', '061000104', 3600.10);

-- Now insert customers (after phone_plan and bank_account are populated)
INSERT INTO customer (name, phone_number, email, address, phone_plan_id, bank_account_id) VALUES
('Alice Johnson',    '555-0101', 'alice.johnson@example.com', '123 Maple St, Springfield', 1,  1),
('Bob Smith',        '555-0102', 'bob.smith@example.com',     '456 Oak St, Springfield',   2,  2),
('Carol Williams',   '555-0103', 'carol.williams@example.com','789 Pine St, Springfield', 3,  3),
('David Brown',      '555-0104', 'david.brown@example.com',   '321 Elm St, Springfield', 4,  4),
('Eva Davis',        '555-0105', 'eva.davis@example.com',     '654 Cedar St, Springfield',5,  5),
('Frank Miller',     '555-0106', 'frank.miller@example.com',  '987 Birch St, Springfield',6,  6),
('Grace Wilson',     '555-0107', 'grace.wilson@example.com',  '147 Spruce St, Springfield',7,  7),
('Henry Moore',      '555-0108', 'henry.moore@example.com',   '258 Willow St, Springfield',8,  8),
('Ivy Taylor',       '555-0109', 'ivy.taylor@example.com',    '369 Aspen St, Springfield',9,  9),
('Jack Anderson',    '555-0110', 'jack.anderson@example.com', '159 Walnut St, Springfield',10,10);

-- Insert call records (after customer is populated)
INSERT INTO call_record (call_start_time, call_end_time, call_duration, data_usage, cost, customer_id) VALUES
('2024-04-01 08:30:00', '2024-04-01 08:35:00',  300, 50, 2.50, 1),
('2024-04-02 09:15:00', '2024-04-02 09:18:20',  200, 30, 1.75, 2),
('2024-04-03 10:45:00', '2024-04-03 10:55:00',  600, 80, 4.00, 3),
('2024-04-04 11:00:00', '2024-04-04 11:02:30',  150, 20, 1.25, 4),
('2024-04-05 12:30:00', '2024-04-05 12:36:40',  400, 60, 3.00, 5),
('2024-04-06 13:45:00', '2024-04-06 13:49:10',  250, 35, 2.20, 6),
('2024-04-07 14:20:00', '2024-04-07 14:28:20',  500, 75, 3.75, 7),
('2024-04-08 15:10:00', '2024-04-08 15:15:10',  350, 55, 2.90, 8),
('2024-04-09 16:50:00', '2024-04-09 16:57:40',  450, 65, 3.50, 9),
('2024-04-10 17:30:00', '2024-04-10 17:31:40',  100, 15, 0.80,10);

-- Insert bills (after customer is populated)
INSERT INTO bill (bill_date, total_amount, due_date, bill_status, customer_id) VALUES
('2024-04-01',  59.99, '2024-04-15', 'Paid',     1),
('2024-04-02',  89.99, '2024-04-16', 'Unpaid',   2),
('2024-04-03', 119.99, '2024-04-17', 'Paid',     3),
('2024-04-04', 149.99, '2024-04-18', 'Unpaid',   4),
('2024-04-05', 199.99, '2024-04-19', 'Paid',     5),
('2024-04-06', 249.99, '2024-04-20', 'Unpaid',   6),
('2024-04-07', 299.99, '2024-04-21', 'Paid',     7),
('2024-04-08', 349.99, '2024-04-22', 'Unpaid',   8),
('2024-04-09', 399.99, '2024-04-23', 'Paid',     9),
('2024-04-10', 449.99, '2024-04-24', 'Unpaid',  10);

-- Insert payments (after bill and bank_account are populated)
INSERT INTO payment (payment_method, payment_type, payment_date, payment_amount, bill_id, bank_account_id) VALUES
('Credit Card', 'Online',    '2024-04-14', 59.99, 1, 1),
('Debit Card',  'In-Person','2024-04-17', 89.99, 2, 2),
('Bank Transfer','Online',   '2024-04-16',119.99, 3, 3),
('Credit Card', 'Online',    '2024-04-18',149.99, 4, 4),
('Debit Card',  'In-Person','2024-04-19',199.99, 5, 5),
('Bank Transfer','Online',   '2024-04-20',249.99, 6, 6),
('Credit Card', 'Online',    '2024-04-21',299.99, 7, 7),
('Debit Card',  'In-Person','2024-04-22',349.99, 8, 8),
('Bank Transfer','Online',   '2024-04-23',399.99, 9, 9),
('Credit Card', 'Online',    '2024-04-24',449.99,10,10);

-- Commit transaction
COMMIT;

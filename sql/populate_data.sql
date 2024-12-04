-- Start transaction and reset tables
BEGIN;

-- Clear existing data
TRUNCATE TABLE phone_plan, bank_account, customer, call_record, bill, payment, address, customer_service, phone_warranty, service_range CASCADE;

-- Reset sequences
ALTER SEQUENCE phone_plan_id_seq RESTART WITH 1;
ALTER SEQUENCE bank_account_id_seq RESTART WITH 1;
ALTER SEQUENCE customer_id_seq RESTART WITH 1;
ALTER SEQUENCE bill_id_seq RESTART WITH 1;
ALTER SEQUENCE payment_id_seq RESTART WITH 1;
ALTER SEQUENCE address_id_seq RESTART WITH 1;
ALTER SEQUENCE customer_service_id_seq RESTART WITH 1;
ALTER SEQUENCE phone_warranty_id_seq RESTART WITH 1;
ALTER SEQUENCE service_range_id_seq RESTART WITH 1;

-- Insert data into phone_plan first (since it's referenced by customer)
INSERT INTO phone_plan (phone_plan_id, plan_type, monthly_charge, data_limit, talk_limit) VALUES
(1, 'Basic',     19.99, 1000,  500),
(2, 'Standard',  29.99, 3000, 1500),
(3, 'Premium',   49.99, 7000, 3500),
(4, 'Unlimited', 69.99, 10000, 999999),
(5, 'Family',    39.99, 5000, 2500),
(6, 'Student',   24.99, 2000, 1000),
(7, 'Business',  59.99, 8000, 4000),
(8, 'Eco',       14.99, 500,  250),
(9, 'Gaming',    54.99, 9000, 4500),
(10, 'Traveler',  64.99, 8500, 4250);

-- Insert data into bank_account (since it's referenced by customer)
-- Manually specifying bank_account_id
INSERT INTO bank_account (bank_account_id, account_holder_name, bank_name, account_number, routing_number, balance) VALUES
(1, 'Alice Johnson', 'Bank of America', '1234567890', '111000025', 2500.75),
(2, 'Bob Smith', 'Chase Bank',      '2345678901', '021000021', 4800.50),
(3, 'Carol Williams', 'Wells Fargo',     '3456789012', '121000248', 3200.00),
(4, 'David Brown', 'Citibank',        '4567890123', '021000089', 1500.25),
(5, 'Eva Davis', 'Capital One',     '5678901234', '051000017', 6100.40),
(6, 'Frank Miller', 'US Bank',         '6789012345', '081000210', 4300.60),
(7, 'Grace Wilson', 'PNC Bank',        '7890123456', '031000053', 2750.30),
(8, 'Henry Moore', 'TD Bank',         '8901234567', '031100649', 3900.90),
(9, 'Ivy Taylor', 'BB&T',            '9012345678', '053000196', 5200.80),
(10, 'Jack Anderson', 'SunTrust',        '0123456789', '061000104', 3600.10);

-- Insert customers (after phone_plan and bank_account are populated)
-- Manually specifying customer_id
INSERT INTO customer (customer_id, name, phone_number, email, phone_plan_id, bank_account_id) VALUES
(1, 'Alice Johnson',    '555-0101', 'alice.johnson@example.com', 1,  1),
(2, 'Bob Smith',        '555-0102', 'bob.smith@example.com',     2,  2),
(3, 'Carol Williams',   '555-0103', 'carol.williams@example.com', 3,  3),
(4, 'David Brown',      '555-0104', 'david.brown@example.com',   4,  4),
(5, 'Eva Davis',        '555-0105', 'eva.davis@example.com',     5,  5),
(6, 'Frank Miller',     '555-0106', 'frank.miller@example.com',  6,  6),
(7, 'Grace Wilson',     '555-0107', 'grace.wilson@example.com',  7,  7),
(8, 'Henry Moore',      '555-0108', 'henry.moore@example.com',   8,  8),
(9, 'Ivy Taylor',       '555-0109', 'ivy.taylor@example.com',    9,  9),
(10, 'Jack Anderson',    '555-0110', 'jack.anderson@example.com', 10, 10);

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
INSERT INTO bill (bill_id, bill_date, total_amount, due_date, bill_status, customer_id) VALUES
(1, '2024-04-01',  59.99, '2024-04-15', 'Paid',     1),
(2, '2024-04-02',  89.99, '2024-04-16', 'Unpaid',   2),
(3, '2024-04-03', 119.99, '2024-04-17', 'Paid',     3),
(4, '2024-04-04', 149.99, '2024-04-18', 'Unpaid',   4),
(5, '2024-04-05', 199.99, '2024-04-19', 'Paid',     5),
(6, '2024-04-06', 249.99, '2024-04-20', 'Unpaid',   6),
(7, '2024-04-07', 299.99, '2024-04-21', 'Paid',     7),
(8, '2024-04-08', 349.99, '2024-04-22', 'Unpaid',   8),
(9, '2024-04-09', 399.99, '2024-04-23', 'Paid',     9),
(10, '2024-04-10', 449.99, '2024-04-24', 'Unpaid',  10);

-- Insert payments (after bill and bank_account are populated)
INSERT INTO payment (payment_method, payment_type, payment_date, payment_amount, bill_id, bank_account_id) VALUES
('Credit Card', 'Online',     '2024-04-14', 59.99, 1, 1),
('Debit Card',  'In-Person', '2024-04-17', 89.99, 2, 2),
('Bank Transfer','Online',    '2024-04-16',119.99, 3, 3),
('Credit Card', 'Online',     '2024-04-18',149.99, 4, 4),
('Debit Card',  'In-Person', '2024-04-19',199.99, 5, 5),
('Bank Transfer','Online',    '2024-04-20',249.99, 6, 6),
('Credit Card', 'Online',     '2024-04-21',299.99, 7, 7),
('Debit Card',  'In-Person', '2024-04-22',349.99, 8, 8),
('Bank Transfer','Online',    '2024-04-23',399.99, 9, 9),
('Credit Card', 'Online',     '2024-04-24',449.99,10,10);

-- Insert data into address
-- Manually specifying address_id and customer_id
INSERT INTO address (address_id, customer_id, street_address, city, state, zip_code) VALUES
(1, 1, '123 Maple St', 'Springfield', 'IL', '62701'),
(2, 2, '456 Oak St', 'Springfield', 'IL', '62702'),
(3, 3, '789 Pine St', 'Springfield', 'IL', '62703'),
(4, 4, '321 Elm St', 'Springfield', 'IL', '62704'),
(5, 5, '654 Cedar St', 'Springfield', 'IL', '62705'),
(6, 6, '987 Birch St', 'Springfield', 'IL', '62706'),
(7, 7, '147 Spruce St', 'Springfield', 'IL', '62707'),
(8, 8, '258 Willow St', 'Springfield', 'IL', '62708'),
(9, 9, '369 Aspen St', 'Springfield', 'IL', '62709'),
(10, 10, '159 Walnut St', 'Springfield', 'IL', '62710');

-- Insert data into customer_service
-- Manually specifying service_id and customer_id
INSERT INTO customer_service (service_id, customer_id, service_date, issue_description, resolution_description) VALUES
(1, 1, '2024-04-05', 'Network connectivity issue', 'Reconfigured network settings'),
(2, 2, '2024-04-06', 'Billing error', 'Adjusted and corrected the bill'),
(3, 3, '2024-04-07', 'Call quality issues', 'Reset call routing preferences'),
(4, 4, '2024-04-08', 'Incorrect data usage charges', 'Refunded overcharged amount'),
(5, 5, '2024-04-09', 'Sim card not working', 'Provided a replacement SIM card'),
(6, 6, '2024-04-10', 'Service outage', 'Resolved through backend maintenance'),
(7, 7, '2024-04-11', 'Account login issue', 'Reset password and updated credentials'),
(8, 8, '2024-04-12', 'Phone warranty claim', 'Approved and replaced the device'),
(9, 9, '2024-04-13', 'Voicemail setup problem', 'Configured voicemail settings'),
(10, 10, '2024-04-14', 'Missed international call charges', 'Issued a credit for missed charges');

-- Insert data into phone_warranty
-- Manually specifying warranty_id and customer_id
INSERT INTO phone_warranty (warranty_id, customer_id, warranty_start_date, warranty_end_date, warranty_status) VALUES
(1, 1, '2023-01-01', '2025-01-01', 'Active'),
(2, 2, '2023-02-01', '2025-02-01', 'Active'),
(3, 3, '2023-03-01', '2025-03-01', 'Active'),
(4, 4, '2023-04-01', '2025-04-01', 'Active'),
(5, 5, '2023-05-01', '2025-05-01', 'Expired'),
(6, 6, '2023-06-01', '2025-06-01', 'Active'),
(7, 7, '2023-07-01', '2025-07-01', 'Active'),
(8, 8, '2023-08-01', '2025-08-01', 'Expired'),
(9, 9, '2023-09-01', '2025-09-01', 'Active'),
(10, 10, '2023-10-01', '2025-10-01', 'Active');

-- Insert data into service_range
-- Manually specifying range_id and customer_id
INSERT INTO service_range (range_id, customer_id, region_name, coverage_area) VALUES
(1, 1, 'North Springfield', 'Downtown and suburbs'),
(2, 2, 'South Springfield', 'Residential and industrial areas'),
(3, 3, 'East Springfield', 'Commercial and residential zones'),
(4, 4, 'West Springfield', 'Urban and suburban localities'),
(5, 5, 'Central Springfield', 'Downtown hub'),
(6, 6, 'Springfield Heights', 'High-altitude coverage'),
(7, 7, 'Springfield Plains', 'Rural and semi-urban areas'),
(8, 8, 'Springfield Lake District', 'Lakeside and surrounding suburbs'),
(9, 9, 'Springfield Parkside', 'Parks and recreational zones'),
(10, 10, 'Springfield West End', 'Industrial and business zones');

-- Commit transaction
COMMIT;

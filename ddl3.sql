-- Phone Plan Table
CREATE TABLE phone_plan (
    phone_plan_id INT PRIMARY KEY,
    plan_type VARCHAR(50) NOT NULL,
    monthly_charge DECIMAL(10, 2) NOT NULL,
    data_limit INT NOT NULL
);

--Bank Account Table
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

--Call Record Table
CREATE TABLE call_record (
    call_id INT PRIMARY KEY,
    call_time DATETIME NOT NULL,
    call_duration INT NOT NULL,
    data_usage INT NOT NULL,
    cost DECIMAL(10, 2) NOT NULL,
    customer_id INT NOT NULL,
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



-- Relationship from customer to phone plan: Many-to-One
-- Each customer can have only one phone plan, but multiple customers can have the same phone plan this is reinforced by the phone_plan_id foreign key in the customer table.

-- Relationship from customer to bank account: One-to-One
-- Each customer can have only one bank account, and each bank account belongs to one customer this is reinforced by the bank_account_id foreign key in the customer table.

-- Relationship from customer to call record: One-to-Many
-- Each customer can have multiple call records, but each call record belongs to one customer this is reinforced by the customer_id foreign key in the call_record table.

-- Relationship from customer to bill: One-to-Many
-- Each customer can have multiple bills, but each bill belongs to one customer this is reinforced bu the customer_id foreign key in the bill table.

-- Relationship from payment to bill: One-to-One
-- Each payment is associated with one bill, and each bill is associated with one payment this is reinforced by the bill_id foreign key in the payment table.

-- Relationship from payment to bank account: Many-to-One
-- Each payment is made from one bank account, but multiple payments can be made from the same bank account this is reinforced by the bank_account_id foreign key in the payment table.
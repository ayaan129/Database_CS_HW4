# COSC 3380 Database HW 4

## Team Members
* Rindy Tuy (ID: 2367978)
* AyaanAli Lakhani (ID: 2335521)
* Cristian Herrera (ID: 2175046)
* FNU Abinanda Manoj (ID: 2098084)

**Instructor:** Carlos Ordonez

# Cell Company Web App

Our web app project is designed for efficient management of a cell phone company's customer data and operations. It allows users to create, populate, and delete database tables for customer records, phone plans, and payment details. Users can view detailed records, including customer profiles, billing summaries, total call durations, and payment histories, enabling comprehensive data insights. The app supports transaction simulations, such as bill payments and plan changes, to streamline operations. With features like billing summary generation and real-time transaction handling, the platform enhances operational efficiency and improves the overall customer experience.



## Quick Start

```bash
# Install dependencies
npm install

# Start the server
node server.js
```

## Trace Folder
Folder containing two files:
* `transaction.sql` - Shows the code for the transaction query
* `query.sql` - Shows the code that our server SQL query runs on

### ER Diagram

![ER Model](CellCompanyERD.jpg)

### Schema

~~~
-- Phone Plan Table
CREATE TABLE phone_plan (
    phone_plan_id INT PRIMARY KEY,
    plan_type VARCHAR(50) NOT NULL,
    monthly_charge DECIMAL(10, 2) NOT NULL,
    data_limit INT NOT NULL
);
~~~
This phone plan relation creates the table holding values for the customer's phone plan ID, the specific phone plan, their monthly charge, and their data limit.

~~~
--Bank Account Table
CREATE TABLE bank_account (
    bank_account_id INT PRIMARY KEY,
    bank_name VARCHAR(255) NOT NULL,
    account_number VARCHAR(50) NOT NULL,
    routing_number VARCHAR(50) NOT NULL,
    balance DECIMAL(10,2) NOT NULL
);
~~~
Bank account relation holds the specifics of the customer's account with their bank like the routing number and their balance.

~~~
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
~~~
Customer holds the personal info of the customers with the company

~~~
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
~~~
Call Record tracks the details of the customer's phone calls along with the data usage and the cost of them.

~~~
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
~~~
Phone Bill holds values about the bill such as the assigned date and due date, the status (paid/unpaid), and the total amount.

~~~
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
~~~
Payment surrounds the payment of the bill considering the amount, the method of payment, and if it was pre/post-paid

~~~
-- Address Table
CREATE TABLE address (
    address_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    street_address VARCHAR(255) NOT NULL,
    city VARCHAR(255) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zip_code VARCHAR(20) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE
);
~~~
Holds customer address details, including street address, city, state, and zip code.
~~~

-- Customer Service Table
CREATE TABLE customer_service (
    service_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    service_date DATE NOT NULL,
    issue_description TEXT NOT NULL,
    resolution_description TEXT,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE
);
~~~
Logs customer service interactions, including service date, issue description, and resolution details.
~~~

-- Phone Warranty Table
CREATE TABLE phone_warranty (
    warranty_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    warranty_start_date DATE NOT NULL,
    warranty_end_date DATE NOT NULL,
    warranty_status VARCHAR(50) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE
);
~~~
Stores warranty details for customers, including warranty period and status.
~~~

-- Service Range Table
CREATE TABLE service_range (
    range_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    region_name VARCHAR(255) NOT NULL,
    coverage_area VARCHAR(255) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE
);
~~~
Defines service coverage areas for customers, including region and coverage area.


### Relationships:

~~~
Customer → Phone Plan (One-to-Many)
Customer → Bank Account (One-to-Many)
Customer → Call Record (One-to-Many)
Customer → Bill (One-to-Many)
Customer → Address (One-to-Many)
Customer → Customer Service (One-to-Many)
Customer → Phone Warranty (One-to-Many)
Customer → Service Range (One-to-Many)

Call Record → Customer (Many-to-One)

Bill → Customer (Many-to-One)
Bill → Payment (One-to-Many)

Payment → Bill (Many-to-One)
Payment → Bank Account (Many-to-One)

Address → Customer (Many-to-One)

Customer Service → Customer (Many-to-One)

Phone Warranty → Customer (Many-to-One)

Service Range → Customer (Many-to-One)

Bank Account → Customer (One-to-Many)
Bank Account → Payment (One-to-Many)
~~~

### Transaction

This transaction query handles the process of paying a customer's unpaid bill. Firstly by declaring an unpaid bill and locking its respective bank account for update. Then check the balance to see if the funds are sufficient enough to pay the bill. If yes, it deducts the funds from the account and sets the bill status to 'Paid' from unpaid. Followed by a payment processed statement. If funds are less than the bill total, there will be an insufficient funds in bank account statement.

~~~
BEGIN;

DO $$
DECLARE
    v_bill_id INT;
    v_customer_id INT;
    v_bank_account_id INT;
    v_total_amount DECIMAL(10,2);
    v_balance DECIMAL(10,2);
BEGIN
    -- Get and lock an unpaid bill
    SELECT bill_id, customer_id, total_amount 
    INTO v_bill_id, v_customer_id, v_total_amount
    FROM bill 
    WHERE bill_status = 'Unpaid'
    LIMIT 1
    FOR UPDATE SKIP LOCKED;

    -- Exit if no unpaid bill found
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No unpaid bills to process.';
    END IF;

    -- Get and lock bank account info
    SELECT ba.bank_account_id, ba.balance 
    INTO v_bank_account_id, v_balance
    FROM customer c
    JOIN bank_account ba ON ba.bank_account_id = c.bank_account_id
    WHERE c.customer_id = v_customer_id
    FOR UPDATE;

    -- Check if sufficient funds are available
    IF v_balance < v_total_amount THEN
        RAISE EXCEPTION 'Insufficient funds for bill %', v_bill_id;
    END IF;

    -- Deduct amount from bank account
    UPDATE bank_account
    SET balance = balance - v_total_amount
    WHERE bank_account_id = v_bank_account_id;

    -- Mark bill as paid
    UPDATE bill
    SET bill_status = 'Paid'
    WHERE bill_id = v_bill_id;

    -- Commit the transaction
    RAISE NOTICE 'Transaction completed successfully for bill %', v_bill_id;
END $$;

-- Commit the transaction
COMMIT;
~~~

### Complex Queries

~~~
SELECT 
    RANK() OVER (ORDER BY SUM(r.call_duration) DESC) AS rank,
    c.customer_id, 
    c.name, 
    SUM(r.call_duration) AS total_call_time,
    ROUND(SUM(r.call_duration)::numeric / 60, 2) AS total_hours
FROM 
    customer c
JOIN 
    call_record r ON c.customer_id = r.customer_id
GROUP BY 
    c.customer_id, c.name
ORDER BY 
    total_call_time DESC;
~~~

Query for calculating the total call time and joins tables call record and customer. This ensures that each customer’s total call duration is calculated based on their call records.

~~~
SELECT 
    p.payment_id, 
    p.payment_date, 
    p.payment_amount, 
    ba.bank_name, 
    ba.account_number, 
    c.name AS customer_name
FROM payment p
JOIN bank_account ba ON p.bank_account_id = ba.bank_account_id
JOIN bill b ON p.bill_id = b.bill_id
JOIN customer c ON b.customer_id = c.customer_id
ORDER BY p.payment_date DESC;
~~~

Payment history query fetches details about each payment made by a customer, including information about the payment method, the bank account, and the customer who made the payment. 

~~~
SELECT 
    c.customer_id, 
    c.name, 
    b.bill_date, 
    b.total_amount, 
    b.due_date, 
    b.bill_status
FROM customer c
JOIN bill b ON c.customer_id = b.customer_id
ORDER BY c.customer_id, b.bill_date;
~~~
The show bill query is used to show the summary of billing information for each customer. This query includes details like the bill date, the amount due, the due date, and the status of each bill, allowing customers or administrators to view billing history or upcoming due bills for individual customers.





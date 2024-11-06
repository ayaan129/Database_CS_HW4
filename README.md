# Cell Company Web App

Our project is a web app for a database of a phone company that tracks the specifics of basic phone plans from the company's perspective. We are able to add a customer with an existing bank account into our database with a select phone plan that is offered. This data can also be deleted from our database. Payment history and bill summaries for customers can be found as well. Along with many other actions of a cell phone company system.



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



Relationships:
~~~
-- Relationship from customer to phone plan: Many-to-One
-- Each customer can have only one phone plan, but multiple customers can have the same phone plan this is reinforced by the phone_plan_id foreign key in the customer table.

-- Relationship from customer to bank account: One-to-One
-- Each customer can have only one bank account, and each bank account belongs to one customer this is reinforced by the bank_account_id foreign key in the customer table.

-- Relationship from customer to call record: One-to-Many
-- Each customer can have multiple call records, but each call record belongs to one customer this is reinforced by the customer_id foreign key in the call_record table.

-- Relationship from customer to bill: One-to-Many
-- Each customer can have multiple bills, but each bill belongs to one customer this is reinforced by the customer_id foreign key in the bill table.

-- Relationship from payment to bill: One-to-One
-- Each payment is associated with one bill, and each bill is associated with one payment this is reinforced by the bill_id foreign key in the payment table.

-- Relationship from payment to bank account: Many-to-One
-- Each payment is made from one bank account, but multiple payments can be made from the same bank account this is reinforced by the bank_account_id foreign key in the payment table.
~~~

### Transaction

This transaction query handles the process of paying a customer's unpaid bill. Firstly by declaring an unpaid bill and locking its respective bank account for update. Then check the balance to see if the funds are sufficient enough to pay the bill. If yes, it deducts the funds from the account and sets the bill status to 'Paid' from unpaid. Followed by a payment processed statement. If funds are less than the bill total, there will be an insufficient funds in bank account statement.

~~~
-- Begin transaction
BEGIN;

-- Select an unpaid bill and lock it for update
DO $$ 
DECLARE
    v_unpaid_bill RECORD;
    v_customer RECORD;
    v_bank_account RECORD;
BEGIN
    -- Select unpaid bill
    SELECT * INTO v_unpaid_bill FROM bill WHERE bill_status = 'Unpaid' LIMIT 1 FOR UPDATE;

    -- Check if an unpaid bill was found
    IF NOT FOUND THEN
        RAISE NOTICE 'No unpaid bills found.';
        RETURN;
    END IF;

    -- Select the customer associated with the bill
    SELECT * INTO v_customer FROM customer WHERE customer_id = v_unpaid_bill.customer_id;

    -- Select and lock the customer's bank account for update
    SELECT * INTO v_bank_account FROM bank_account WHERE bank_account_id = v_customer.bank_account_id FOR UPDATE;

    -- Check if the bank account has sufficient balance
    IF v_bank_account.balance < v_unpaid_bill.total_amount THEN
        RAISE EXCEPTION 'Insufficient funds in bank account for customer %.', v_customer.name;
    END IF;

    -- Deduct the amount from the bank account
    UPDATE bank_account
    SET balance = balance - v_unpaid_bill.total_amount
    WHERE bank_account_id = v_bank_account.bank_account_id;

    -- Update the bill status to 'Paid'
    UPDATE bill
    SET bill_status = 'Paid'
    WHERE bill_id = v_unpaid_bill.bill_id;
    
    -- Optional: Provide a success message
    RAISE NOTICE 'Payment processed for customer %.', v_customer.name;
    
END $$;

-- Commit transaction
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





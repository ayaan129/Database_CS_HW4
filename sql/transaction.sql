BEGIN;

-- Process all unpaid bills
DO $$
DECLARE
    unpaid_bill RECORD;
    customer RECORD;
    bank_account RECORD;
BEGIN
    FOR unpaid_bill IN
        SELECT * FROM bill WHERE bill_status = 'Unpaid' FOR UPDATE
    LOOP
        -- Get customer details
        SELECT * INTO customer FROM customer WHERE customer_id = unpaid_bill.customer_id;
        
        -- Get and lock bank account
        SELECT * INTO bank_account FROM bank_account b WHERE b.bank_account_id = customer.bank_account_id FOR UPDATE;
        
        -- Check for sufficient funds
        IF bank_account.balance >= unpaid_bill.total_amount THEN
            -- Deduct amount from bank account
            UPDATE bank_account AS b
            SET balance = b.balance - unpaid_bill.total_amount
            WHERE b.bank_account_id = bank_account.bank_account_id;
            
            -- Update bill status to 'Paid'
            UPDATE bill AS bl
            SET bill_status = 'Paid'
            WHERE bl.bill_id = unpaid_bill.bill_id;
            
            -- Insert payment record
            INSERT INTO payment (
                payment_method, payment_type, payment_date, payment_amount, bill_id, bank_account_id
            ) VALUES (
                'Bank Transfer', 'Automatic', CURRENT_DATE, unpaid_bill.total_amount, unpaid_bill.bill_id, bank_account.bank_account_id
            );
            
            -- Success message
            RAISE NOTICE 'Payment processed for customer %.', customer.name;
        ELSE
            -- Insufficient funds message
            RAISE NOTICE 'Insufficient funds for customer %.', customer.name;
        END IF;
    END LOOP;
END $$;

-- Commit transaction
COMMIT;

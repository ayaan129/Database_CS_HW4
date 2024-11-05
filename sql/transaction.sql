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

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


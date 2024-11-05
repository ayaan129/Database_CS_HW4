-- delete_data.sql

-- Start a transaction to ensure all deletions are atomic
BEGIN;

-- Disable foreign key constraints temporarily (optional, if needed)
-- This step is not strictly necessary when using TRUNCATE ... CASCADE
-- SET session_replication_role = 'replica';

-- Truncate all tables to remove all data
TRUNCATE TABLE payment CASCADE;
TRUNCATE TABLE bill CASCADE;
TRUNCATE TABLE call_record CASCADE;
TRUNCATE TABLE customer CASCADE;
TRUNCATE TABLE bank_account CASCADE;
TRUNCATE TABLE phone_plan CASCADE;

-- Alternatively, if you prefer to use DELETE statements in order:
-- DELETE FROM payment;
-- DELETE FROM bill;
-- DELETE FROM call_record;
-- DELETE FROM customer;
-- DELETE FROM bank_account;
-- DELETE FROM phone_plan;

-- Commit the transaction
COMMIT;

-- Re-enable foreign key constraints if they were disabled
-- SET session_replication_role = 'origin';

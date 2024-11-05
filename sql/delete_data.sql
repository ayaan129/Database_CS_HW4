-- delete_data.sql

-- Start a transaction to ensure all deletions are atomic
BEGIN;

-- Truncate all tables to remove all data
TRUNCATE TABLE payment CASCADE;
TRUNCATE TABLE bill CASCADE;
TRUNCATE TABLE call_record CASCADE;
TRUNCATE TABLE customer CASCADE;
TRUNCATE TABLE bank_account CASCADE;
TRUNCATE TABLE phone_plan CASCADE;



-- Commit the transaction
COMMIT;


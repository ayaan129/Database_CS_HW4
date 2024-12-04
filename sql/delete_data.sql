-- delete_data.sql

-- Start a transaction to ensure all deletions are atomic
BEGIN;

-- Drop existing tables
DROP TABLE IF EXISTS payment CASCADE;
DROP TABLE IF EXISTS bill CASCADE;
DROP TABLE IF EXISTS call_record CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS bank_account CASCADE;
DROP TABLE IF EXISTS phone_plan CASCADE;
DROP TABLE IF EXISTS address CASCADE;
DROP TABLE IF EXISTS customer_service CASCADE;
DROP TABLE IF EXISTS phone_warranty CASCADE;
DROP TABLE IF EXISTS service_range CASCADE;

-- Commit the transaction
COMMIT;

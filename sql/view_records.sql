-- sql/view_records.sql
SELECT 
    c.customer_id,
    c.name,
    c.phone_number,
    c.email,
    c.address,
    p.plan_type,
    p.monthly_charge,
    p.data_limit,
    p.talk_limit,
    b.bank_name,
    b.account_number
FROM customer c
JOIN phone_plan p ON c.phone_plan_id = p.phone_plan_id
JOIN bank_account b ON c.bank_account_id = b.bank_account_id
LIMIT 10;

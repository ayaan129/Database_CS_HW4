-- sql/payment_history.sql
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

-- sql/billing_summary.sql
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

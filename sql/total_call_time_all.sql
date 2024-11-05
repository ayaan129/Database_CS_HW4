-- sql/total_call_time_all.sql
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

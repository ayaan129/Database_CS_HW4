const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
const path = require('path');
const cors = require('cors');

const app = express();
app.use(bodyParser.json());
app.use(cors()); // Enable CORS for cross-origin requests

// Serve static files from the "public" directory
app.use(express.static(path.join(__dirname, 'public')));

// PostgreSQL Pool Configuration
const pool = new Pool({
    user: 'team19', // Updated to 'team19' as per role creation
    host: 'localhost',
    database: 'cellphone', // Updated to 'cellphone' database
    password: '1234',
    port: 5432,
});

// Utility function for querying the database
const query = (text, params) => pool.query(text, params);

/*
    CRUD Operations for Customers
*/

// Fetch all customers
app.get('/customers', async (req, res) => {
    try {
        const result = await query('SELECT * FROM customer');
        res.json(result.rows);
    } catch (err) {
        console.error(err.message);
        res.sendStatus(500);
    }
});

// Add a new customer
app.post('/customers', async (req, res) => {
    const { customer_id, name, number, email, address, bank_account_id } = req.body;
    try {
        const result = await query(
            'INSERT INTO customer (customer_id, name, number, email, address, bank_account_id) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
            [customer_id, name, number, email, address, bank_account_id]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.sendStatus(500);
    }
});

// Update a customer by ID
app.put('/customers/:id', async (req, res) => {
    const { id } = req.params;
    const { name, number, email, address, bank_account_id } = req.body;
    try {
        const result = await query(
            'UPDATE customer SET name = $1, number = $2, email = $3, address = $4, bank_account_id = $5 WHERE customer_id = $6 RETURNING *',
            [name, number, email, address, bank_account_id, id]
        );
        if (result.rows.length === 0) {
            return res.sendStatus(404);
        }
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.sendStatus(500);
    }
});

// Delete a customer by ID
app.delete('/customers/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const result = await query('DELETE FROM customer WHERE customer_id = $1 RETURNING *', [id]);
        if (result.rows.length === 0) {
            return res.sendStatus(404);
        }
        res.sendStatus(204);
    } catch (err) {
        console.error(err.message);
        res.sendStatus(500);
    }
});

/*
    CRUD Operations for Phone Plans
*/

// Fetch all phone plans
app.get('/phone-plans', async (req, res) => {
    try {
        const result = await query('SELECT * FROM phone_plan');
        res.json(result.rows);
    } catch (err) {
        console.error(err.message);
        res.sendStatus(500);
    }
});

// Add a new phone plan
app.post('/phone-plans', async (req, res) => {
    const { phone_plan_id, customer_id, plan_type, monthly_charge, data_limit, talk_time } = req.body;
    try {
        const result = await query(
            `INSERT INTO phone_plan 
            (phone_plan_id, customer_id, plan_type, monthly_charge, data_limit, talk_time) 
            VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
            [phone_plan_id, customer_id, plan_type, monthly_charge, data_limit, talk_time]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.sendStatus(500);
    }
});

// Update a phone plan by ID
app.put('/phone-plans/:id', async (req, res) => {
    const { id } = req.params;
    const { customer_id, plan_type, monthly_charge, data_limit, talk_time } = req.body;
    try {
        const result = await query(
            `UPDATE phone_plan 
            SET customer_id = $1, plan_type = $2, monthly_charge = $3, data_limit = $4, talk_time = $5 
            WHERE phone_plan_id = $6 RETURNING *`,
            [customer_id, plan_type, monthly_charge, data_limit, talk_time, id]
        );
        if (result.rows.length === 0) {
            return res.sendStatus(404);
        }
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.sendStatus(500);
    }
});

// Delete a phone plan by ID
app.delete('/phone-plans/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const result = await query('DELETE FROM phone_plan WHERE phone_plan_id = $1 RETURNING *', [id]);
        if (result.rows.length === 0) {
            return res.sendStatus(404);
        }
        res.sendStatus(204);
    } catch (err) {
        console.error(err.message);
        res.sendStatus(500);
    }
});

/*
    CRUD Operations for Call Records
*/

// Fetch all call records
app.get('/call-records', async (req, res) => {
    try {
        const result = await query('SELECT * FROM call_record');
        res.json(result.rows);
    } catch (err) {
        console.error(err.message);
        res.sendStatus(500);
    }
});

// Add a new call record
app.post('/call-records', async (req, res) => {
    const { call_id, phone_plan_id, call_time, call_duration, cost } = req.body;
    try {
        const result = await query(
            `INSERT INTO call_record 
            (call_id, phone_plan_id, call_time, call_duration, cost) 
            VALUES ($1, $2, $3, $4, $5) RETURNING *`,
            [call_id, phone_plan_id, call_time, call_duration, cost]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.sendStatus(500);
    }
});

// Update a call record by ID
app.put('/call-records/:id', async (req, res) => {
    const { id } = req.params;
    const { phone_plan_id, call_time, call_duration, cost } = req.body;
    try {
        const result = await query(
            `UPDATE call_record 
            SET phone_plan_id = $1, call_time = $2, call_duration = $3, cost = $4 
            WHERE call_id = $5 RETURNING *`,
            [phone_plan_id, call_time, call_duration, cost, id]
        );
        if (result.rows.length === 0) {
            return res.sendStatus(404);
        }
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.sendStatus(500);
    }
});

// Delete a call record by ID
app.delete('/call-records/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const result = await query('DELETE FROM call_record WHERE call_id = $1 RETURNING *', [id]);
        if (result.rows.length === 0) {
            return res.sendStatus(404);
        }
        res.sendStatus(204);
    } catch (err) {
        console.error(err.message);
        res.sendStatus(500);
    }
});

/*
    CRUD Operations for Bills
*/

// Fetch all bills
app.get('/bills', async (req, res) => {
    try {
        const result = await query('SELECT * FROM bill');
        res.json(result.rows);
    } catch (err) {
        console.error(err.message);
        res.sendStatus(500);
    }
});

// Add a new bill
app.post('/bills', async (req, res) => {
    const { bill_id, phone_plan_id, bill_date, total, due_date, status } = req.body;
    try {
        const result = await query(
            `INSERT INTO bill 
            (bill_id, phone_plan_id, bill_date, total, due_date, status) 
            VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
            [bill_id, phone_plan_id, bill_date, total, due_date, status]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.sendStatus(500);
    }
});

// Update a bill by ID
app.put('/bills/:id', async (req, res) => {
    const { id } = req.params;
    const { phone_plan_id, bill_date, total, due_date, status } = req.body;
    try {
        const result = await query(
            `UPDATE bill 
            SET phone_plan_id = $1, bill_date = $2, total = $3, due_date = $4, status = $5 
            WHERE bill_id = $6 RETURNING *`,
            [phone_plan_id, bill_date, total, due_date, status, id]
        );
        if (result.rows.length === 0) {
            return res.sendStatus(404);
        }
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.sendStatus(500);
    }
});

// Delete a bill by ID
app.delete('/bills/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const result = await query('DELETE FROM bill WHERE bill_id = $1 RETURNING *', [id]);
        if (result.rows.length === 0) {
            return res.sendStatus(404);
        }
        res.sendStatus(204);
    } catch (err) {
        console.error(err.message);
        res.sendStatus(500);
    }
});

/*
    CRUD Operations for Payments
*/

// Fetch all payments
app.get('/payments', async (req, res) => {
    try {
        const result = await query('SELECT * FROM payment');
        res.json(result.rows);
    } catch (err) {
        console.error(err.message);
        res.sendStatus(500);
    }
});

// Add a new payment
app.post('/payments', async (req, res) => {
    const { payment_id, bill_id, payment_method, payment_type, payment_date, amount, bank_account_id } = req.body;
    try {
        const result = await query(
            `INSERT INTO payment 
            (payment_id, bill_id, payment_method, payment_type, payment_date, amount, bank_account_id) 
            VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
            [payment_id, bill_id, payment_method, payment_type, payment_date, amount, bank_account_id]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.sendStatus(500);
    }
});

// Update a payment by ID
app.put('/payments/:id', async (req, res) => {
    const { id } = req.params;
    const { bill_id, payment_method, payment_type, payment_date, amount, bank_account_id } = req.body;
    try {
        const result = await query(
            `UPDATE payment 
            SET bill_id = $1, payment_method = $2, payment_type = $3, payment_date = $4, amount = $5, bank_account_id = $6 
            WHERE payment_id = $7 RETURNING *`,
            [bill_id, payment_method, payment_type, payment_date, amount, bank_account_id, id]
        );
        if (result.rows.length === 0) {
            return res.sendStatus(404);
        }
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.sendStatus(500);
    }
});

// Delete a payment by ID
app.delete('/payments/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const result = await query('DELETE FROM payment WHERE payment_id = $1 RETURNING *', [id]);
        if (result.rows.length === 0) {
            return res.sendStatus(404);
        }
        res.sendStatus(204);
    } catch (err) {
        console.error(err.message);
        res.sendStatus(500);
    }
});

/*
    CRUD Operations for Bank Accounts
*/

// Fetch all bank accounts
app.get('/bank-accounts', async (req, res) => {
    try {
        const result = await query('SELECT * FROM bank_account');
        res.json(result.rows);
    } catch (err) {
        console.error(err.message);
        res.sendStatus(500);
    }
});

// Add a new bank account
app.post('/bank-accounts', async (req, res) => {
    const { account_id, bank_name, account_number, routing_number, balance, account_holder_name } = req.body;
    try {
        const result = await query(
            `INSERT INTO bank_account 
            (account_id, bank_name, account_number, routing_number, balance, account_holder_name) 
            VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
            [account_id, bank_name, account_number, routing_number, balance, account_holder_name]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.sendStatus(500);
    }
});

// Update a bank account by ID
app.put('/bank-accounts/:id', async (req, res) => {
    const { id } = req.params;
    const { bank_name, account_number, routing_number, balance, account_holder_name } = req.body;
    try {
        const result = await query(
            `UPDATE bank_account 
            SET bank_name = $1, account_number = $2, routing_number = $3, balance = $4, account_holder_name = $5 
            WHERE account_id = $6 RETURNING *`,
            [bank_name, account_number, routing_number, balance, account_holder_name, id]
        );
        if (result.rows.length === 0) {
            return res.sendStatus(404);
        }
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err.message);
        res.sendStatus(500);
    }
});

// Delete a bank account by ID
app.delete('/bank-accounts/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const result = await query('DELETE FROM bank_account WHERE account_id = $1 RETURNING *', [id]);
        if (result.rows.length === 0) {
            return res.sendStatus(404);
        }
        res.sendStatus(204);
    } catch (err) {
        console.error(err.message);
        res.sendStatus(500);
    }
});

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
const path = require('path');
const cors = require('cors');
const fs = require('fs');

const app = express();
app.use(bodyParser.json());
app.use(cors()); // Enable CORS for cross-origin requests

// Serve static files from the "public" directory
app.use(express.static(path.join(__dirname, 'public')));

// PostgreSQL Pool Configuration
const pool = new Pool({
    user: 'team19', // Ensure this matches your PostgreSQL user
    host: 'localhost',
    database: 'cellphone', // Ensure this matches your PostgreSQL database
    password: '1234', // Use environment variables for security in production
    port: 5432,
});

// Utility function for querying the database
const query = (text, params) => pool.query(text, params);

/*
    Initialize and Populate Database
*/

// Initialize Database (Run the SQL script to create tables)
app.post('/init-db', async (req, res) => {
    try {
        const sqlFilePath = path.join(__dirname, 'db', 'init.sql');
        const sql = fs.readFileSync(sqlFilePath, 'utf-8');
        await pool.query(sql);
        res.status(200).send('Database initialized successfully.');
    } catch (err) {
        console.error('Error initializing database:', err.message);
        res.status(500).send('Failed to initialize the database.');
    }
});

// Populate Database with Sample Data (Assuming you have a populate.sql script)
app.post('/populate', async (req, res) => {
    try {
        const sqlFilePath = path.join(__dirname, 'db', 'populate.sql');
        const sql = fs.readFileSync(sqlFilePath, 'utf-8');
        await pool.query(sql);
        res.status(200).send('Database populated successfully.');
    } catch (err) {
        console.error('Error populating database:', err.message);
        res.status(500).send('Failed to populate the database.');
    }
});

/*
    CRUD Operations for Phone Plans
*/

// Fetch all phone plans
app.get('/phone_plans', async (req, res) => {
    try {
        const result = await query('SELECT * FROM phone_plan ORDER BY phone_plan_id');
        res.json(result.rows);
    } catch (err) {
        console.error('Error fetching phone plans:', err.message);
        res.sendStatus(500);
    }
});


/*
    CRUD Operations for Bank Accounts
*/

// Fetch all bank accounts
app.get('/bank_accounts', async (req, res) => {
    try {
        const result = await query('SELECT * FROM bank_account ORDER BY bank_account_id');
        res.json(result.rows);
    } catch (err) {
        console.error('Error fetching bank accounts:', err.message);
        res.sendStatus(500);
    }
});



/*
    CRUD Operations for Customers
*/

// Fetch all customers
app.get('/customers', async (req, res) => {
    try {
        const result = await query(`
            SELECT 
                c.*, 
                pp.plan_type, 
                pp.monthly_charge, 
                pp.data_limit, 
                pp.talk_time,
                ba.bank_name, 
                ba.account_number, 
                ba.routing_number, 
                ba.balance
            FROM customer c
            JOIN phone_plan pp ON c.phone_plan_id = pp.phone_plan_id
            JOIN bank_account ba ON c.bank_account_id = ba.bank_account_id
            ORDER BY c.customer_id
        `);
        res.json(result.rows);
    } catch (err) {
        console.error('Error fetching customers:', err.message);
        res.sendStatus(500);
    }
});

// Fetch a single customer by ID
app.get('/customer/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const result = await query(`
            SELECT 
                c.*, 
                pp.plan_type, 
                pp.monthly_charge, 
                pp.data_limit, 
                pp.talk_time,
                ba.bank_name, 
                ba.account_number, 
                ba.routing_number, 
                ba.balance
            FROM customer c
            JOIN phone_plan pp ON c.phone_plan_id = pp.phone_plan_id
            JOIN bank_account ba ON c.bank_account_id = ba.bank_account_id
            WHERE c.customer_id = $1
        `, [id]);

        if (result.rows.length === 0) {
            return res.status(404).send('Customer not found.');
        }
        res.json(result.rows[0]);
    } catch (err) {
        console.error('Error fetching customer:', err.message);
        res.sendStatus(500);
    }
});

/*
    CRUD Operations for Call Records
*/

// Fetch all call records
app.get('/call_records', async (req, res) => {
    try {
        const result = await query(`
            SELECT 
                cr.*, 
                c.name AS customer_name, 
                c.phone_number
            FROM call_record cr
            JOIN customer c ON cr.customer_id = c.customer_id
            ORDER BY cr.call_id
        `);
        res.json(result.rows);
    } catch (err) {
        console.error('Error fetching call records:', err.message);
        res.sendStatus(500);
    }
});



/*
    CRUD Operations for Bills
*/

// Fetch all bills
app.get('/bills', async (req, res) => {
    try {
        const result = await query(`
            SELECT 
                b.*, 
                c.name AS customer_name, 
                c.email, 
                c.phone_number
            FROM bill b
            JOIN customer c ON b.customer_id = c.customer_id
            ORDER BY b.bill_id
        `);
        res.json(result.rows);
    } catch (err) {
        console.error('Error fetching bills:', err.message);
        res.sendStatus(500);
    }
});

/*
    CRUD Operations for Payments
*/

// Fetch all payments
app.get('/payments', async (req, res) => {
    try {
        const result = await query(`
            SELECT 
                p.*, 
                b.bill_date, 
                b.total_amount, 
                ba.bank_name, 
                ba.account_number
            FROM payment p
            JOIN bill b ON p.bill_id = b.bill_id
            JOIN bank_account ba ON p.bank_account_id = ba.bank_account_id
            ORDER BY p.payment_id
        `);
        res.json(result.rows);
    } catch (err) {
        console.error('Error fetching payments:', err.message);
        res.sendStatus(500);
    }
});

/*
    Start the Server
*/

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});

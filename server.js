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

// Utility function to execute SQL files
const executeSQLFile = async (filePath) => {
    const sql = fs.readFileSync(filePath, 'utf8');
    return pool.query(sql);
};

// Create tables route
app.get('/create-tables', async (req, res) => {
    try {
        await executeSQLFile(path.join(__dirname, 'sql', 'create_tables.sql'));
        res.json({ message: "Tables created successfully!" });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Error creating tables.", error: error.message });
    }
});

// Populate data route
app.get('/populate-data', async (req, res) => {
    try {
        await executeSQLFile(path.join(__dirname, 'sql', 'populate_data.sql'));
        res.json({ message: "Data populated successfully!" });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Error populating data.", error: error.message });
    }
});

// Delete data route
app.get('/delete-data', async (req, res) => {
    try {
        await executeSQLFile(path.join(__dirname, 'sql', 'delete_data.sql'));
        res.json({ message: "Data deleted successfully!" });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Error deleting data.", error: error.message });
    }
});

// View records route
app.get('/view-records', async (req, res) => {
    try {
        const filePath = path.join(__dirname, 'sql', 'view_records.sql');
        const result = await executeSQLFile(filePath);
        res.json({ records: result.rows });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Error fetching records.", error: error.message });
    }
});

// Run transaction route
app.get('/run-transaction', async (req, res) => {
    try {
        const filePath = path.join(__dirname, 'sql', 'transaction.sql');
        await executeSQLFile(filePath);
        res.json({ message: "Transaction executed successfully!" });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Error executing transaction.", error: error.message });
    }
});

// Billing summary route
app.get('/billing-summary', async (req, res) => {
    try {
        const filePath = path.join(__dirname, 'sql', 'billing_summary.sql');
        const result = await executeSQLFile(filePath);
        res.json({ records: result.rows });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Error fetching billing summary.", error: error.message });
    }
});

// Total call time for all customers route
app.get('/total-call-time-all', async (req, res) => {
    try {
        const filePath = path.join(__dirname, 'sql', 'total_call_time_all.sql');
        const result = await executeSQLFile(filePath);

        if (result.rows.length === 0) {
            res.json({ message: "No call records found for any customer." });
        } else {
            res.json({ records: result.rows });
        }
    } catch (error) {
        console.error('Error fetching total call time for all customers:', error);
        res.status(500).json({ message: "Error fetching total call time.", error: error.message });
    }
});

// High data usage route
app.get('/high-data-usage', async (req, res) => {
    try {
        const filePath = path.join(__dirname, 'sql', 'high_data_usage.sql');
        const result = await executeSQLFile(filePath);
        console.log('High Data Usage Query Result:', result);
        console.log('High Data Usage Records:', result.rows);
        res.json({ records: result.rows });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Error fetching high data usage customers.", error: error.message });
    }
});

// Payment history route
app.get('/payment-history', async (req, res) => {
    try {
        const filePath = path.join(__dirname, 'sql', 'payment_history.sql');
        const result = await executeSQLFile(filePath);
        res.json({ records: result.rows });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Error fetching payment history.", error: error.message });
    }
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});

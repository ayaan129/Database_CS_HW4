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
    database: 'cellphone',
    password: '1234',
    port: 5432,
});

// Set client to capture NOTICE messages
pool.on('connect', (client) => {
    client.query('SET client_min_messages TO NOTICE');
});

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

// Process transaction route
app.post('/process-transaction', async (req, res) => {
    const client = await pool.connect();
    const startTime = Date.now();
    
    try {
        
        const filePath = path.join(__dirname, 'sql', 'transaction.sql');
        const result = await executeSQLFile(filePath);

        const endTime = Date.now();
        const duration = endTime - startTime;
        
        // Check for NOTICE messages in the result
        const notices = result.length > 0 ? result[result.length - 1] : null;
        const message = notices?.rows?.[0]?.message || 'Transaction processed successfully';
        
        res.json({
            status: 'success',
            message: message,
            duration: duration,
            details: notices?.rows?.[0] || {}
        });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Error processing transaction:', error);
        
        // Format user-friendly error message
        let errorMessage = error.message;
        if (error.message.includes('No unpaid bills')) {
            errorMessage = 'No unpaid bills to process.';
        } else if (error.message.includes('Insufficient funds')) {
            errorMessage = 'Insufficient funds in the bank account.';
        }

        
        res.status(500).json({
            status: 'error',
            message: errorMessage,
            duration: Date.now() - startTime
        });
    } finally {
        client.release();
    }
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});

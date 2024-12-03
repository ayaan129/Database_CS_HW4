document.getElementById("createTablesBtn").addEventListener("click", createTables);
document.getElementById("populateDataBtn").addEventListener("click", populateData);
document.getElementById("deleteDataBtn").addEventListener("click", deleteData);
document.getElementById("viewRecordsBtn").addEventListener("click", viewRecords);
document.getElementById("billingSummaryBtn").addEventListener("click", billingSummary);
document.getElementById("dataUsageBtn").addEventListener("click", totalCallTime);
document.getElementById("paymentHistoryBtn").addEventListener("click", paymentHistory);
document.getElementById("processTransactionBtn").addEventListener("click", processTransaction);
document.getElementById("simulateTransactionsBtn").addEventListener("click", simulateTransactions);

const outputDiv = document.getElementById("output");


function createTables() {
    fetch('/create-tables').then(response => response.json()).then(data => {
        outputDiv.innerHTML = `<pre>${data.message}</pre>`;
    });
}

function populateData() {
    fetch('/populate-data').then(response => response.json()).then(data => {
        outputDiv.innerHTML = `<pre>${data.message}</pre>`;
    });
}

function deleteData() {
    if (confirm("Are you sure you want to delete all data?")) {
        fetch('/delete-data').then(response => response.json()).then(data => {
            outputDiv.innerHTML = `<pre>${data.message}</pre>`;
        });
    }
}

function viewRecords() {
    fetch('/view-records')
        .then(response => response.json())
        .then(data => {
            // Add a more descriptive title
            displayData(data.records, 'Customer Records with Plan & Bank Details');
        })
        .catch(error => {
            outputDiv.innerHTML = `<pre>Error: ${error.message}</pre>`;
        });
}



function billingSummary() {
    fetch('/billing-summary')
        .then(response => response.json())
        .then(data => displayData(data.records, 'Billing Summary'));
}

function totalCallTime(){fetch('/total-call-time-all')
        .then(response => response.json())
        .then(data => displayData(data.records, 'Total Call Time Report'));
}

function paymentHistory() {
    fetch('/payment-history')
        .then(response => response.json())
        .then(data => displayData(data.records, 'Payment History'));
}

function processTransaction() {
    fetch('/process-transaction', {
        method: 'POST'
    })
    .then(response => response.json())
    .then(data => {
        const messageClass = data.status === 'success' ? 'success' : 'error';
        outputDiv.innerHTML = `<div class="message ${messageClass}">
            <p>${data.message}</p>
        </div>`;
    })
    .catch(error => {
        outputDiv.innerHTML = `<div class="message error">
            <p>Error: ${error.message}</p>
        </div>`;
    });
}
//function to process transaction button
function processTransaction() {
    fetch('/process-transaction', {
        method: 'POST'
    })
    .then(response => response.json())
    .then(data => {
        const messageClass = data.status === 'success' ? 'success' : 'error';
        outputDiv.innerHTML = `<div class="message ${messageClass}">
            <p>${data.message}</p>
        </div>`;
    })
    .catch(error => {
        outputDiv.innerHTML = `<div class="message error">
            <p>Error: ${error.message}</p>
        </div>`;
    });
}


async function simulateTransactions() {
    const NUM_TRANSACTIONS = 5; // Number of concurrent transactions to simulate
    const transactions = [];
    const startTime = Date.now();
    
    outputDiv.innerHTML = '<div class="message info">Starting transaction simulation...</div>';
    
    // Create multiple concurrent transactions
    for (let i = 0; i < NUM_TRANSACTIONS; i++) {
        const transaction = fetch('/process-transaction', {
            method: 'POST',
            headers: {
                'X-Transaction-ID': `sim-${i + 1}` // Add transaction ID for tracking
            }
        })
        .then(response => response.json())
        .then(data => {
            const endTime = Date.now();
            const duration = endTime - startTime;
            return {
                id: i + 1,
                status: data.status,
                message: data.message,
                duration: duration
            };
        })
        .catch(error => ({
            id: i + 1,
            status: 'error',
            message: error.message,
            duration: Date.now() - startTime
        }));
        
        transactions.push(transaction);
    }
    
    try {
        // Wait for all transactions to complete
        const results = await Promise.all(transactions);
        
        // Display results in a formatted table
        let output = `
            <div class="message info">
                <h3>Transaction Simulation Results</h3>
                <table class="transaction-table">
                    <thead>
                        <tr>
                            <th>Transaction ID</th>
                            <th>Status</th>
                            <th>Duration (ms)</th>
                            <th>Message</th>
                        </tr>
                    </thead>
                    <tbody>
        `;
        
        results.forEach(result => {
            const statusClass = result.status === 'success' ? 'success' : 'error';
            output += `
                <tr>
                    <td>Transaction ${result.id}</td>
                    <td class="${statusClass}">${result.status}</td>
                    <td>${result.duration}</td>
                    <td>${result.message}</td>
                </tr>
            `;
        });
        
        output += `
                    </tbody>
                </table>
                <p>Total simulation time: ${Date.now() - startTime}ms</p>
            </div>
        `;
        
        // Add styles for the table
        const style = document.createElement('style');
        style.textContent = `
            .transaction-table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 15px;
                background: white;
                border-radius: 8px;
                overflow: hidden;
            }
            .transaction-table th,
            .transaction-table td {
                padding: 12px;
                text-align: left;
                border-bottom: 1px solid #eee;
            }
            .transaction-table th {
                background: #f5f5f5;
                font-weight: 600;
            }
            .transaction-table td.success {
                color: #28a745;
            }
            .transaction-table td.error {
                color: #dc3545;
            }
        `;
        document.head.appendChild(style);
        
        outputDiv.innerHTML = output;
    } catch (error) {
        outputDiv.innerHTML = `
            <div class="message error">
                <p>Error in simulation: ${error.message}</p>
            </div>
        `;
    }
}

function displayData(records, title = 'Records') {
     let output = `<div class="table-caption">${title}</div>`;

    if (records.length > 0) {
        output += '<table class="data-table"><tr>';
        
        
        // Headers
        for (let key in records[0]) {
            output += `<th>${key.replace(/_/g, ' ').toUpperCase()}</th>`;
        }
        output += '</tr>';

        // Rows
        records.forEach(record => {
            output += '<tr>';
            for (let key in record) {
                let value = record[key];
                // Format based on value type
                if (typeof value === 'number' && key.includes('amount') || key.includes('charge')) {
                    value = `$${value}`;
                } else if (value instanceof Date || key.includes('date')) {
                    value = new Date(value).toLocaleDateString();
                }
                output += `<td>${value ?? '-'}</td>`;
            }
            output += '</tr>';
        });
        output += '</table>';
    } else {
        output += '<p>No records found.</p>';
    }
    
    outputDiv.innerHTML = output;
}

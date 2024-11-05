document.getElementById("createTablesBtn").addEventListener("click", createTables);
document.getElementById("populateDataBtn").addEventListener("click", populateData);
document.getElementById("deleteDataBtn").addEventListener("click", deleteData);
document.getElementById("viewRecordsBtn").addEventListener("click", viewRecords);
document.getElementById("runTransactionBtn").addEventListener("click", runTransaction);
document.getElementById("billingSummaryBtn").addEventListener("click", billingSummary);
document.getElementById("dataUsageBtn").addEventListener("click", totalCallTime);
document.getElementById("paymentHistoryBtn").addEventListener("click", paymentHistory);

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


function runTransaction() {
    fetch('/run-transaction').then(response => response.json()).then(data => {
        outputDiv.innerHTML = `<pre>${data.message}</pre>`;
    });
}

function billingSummary() {
    fetch('/billing-summary')
        .then(response => response.json())
        .then(data => displayData(data.records, 'Billing Summary'));
}

function totalCallTime(){fetch('/total-call-time-all')
        .then(response => response.json())
        .then(data => displayData(data.records, 'High Data Usage Report'));
}

function highDataUsage() {
    fetch('/high-data-usage')
        .then(response => response.json())
        .then(data => displayData(data.records, 'High Data Usage Report'));
}

function paymentHistory() {
    fetch('/payment-history')
        .then(response => response.json())
        .then(data => displayData(data.records, 'Payment History'));
}

function displayData(records, title = 'Records') {
    let output = `
        <style>
            .data-table {
                border-collapse: collapse;
                width: 100%;
                margin: 20px 0;
                font-family: Arial, sans-serif;
            }
            .data-table th {
                background-color: #4CAF50;
                color: white;
                padding: 12px;
                text-align: left;
            }
            .data-table td {
                padding: 8px;
                border-bottom: 1px solid #ddd;
            }
            .data-table tr:nth-child(even) {
                background-color: #f2f2f2;
            }
            .data-table tr:hover {
                background-color: #ddd;
            }
            .table-caption {
                font-size: 1.2em;
                font-weight: bold;
                margin-bottom: 10px;
            }
        </style>
        <div class="table-caption">${title}</div>
    `;

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

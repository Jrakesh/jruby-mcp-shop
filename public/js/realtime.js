document.addEventListener('DOMContentLoaded', function() {
    const formatter = new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD'
    });

    function updateMetrics() {
        fetch('/api/analytics/realtime')
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                // Update revenue metrics
                document.getElementById('today-revenue').textContent = 
                    formatter.format(data.today_revenue || 0);
                document.getElementById('monthly-revenue').textContent = 
                    formatter.format(data.monthly_revenue || 0);
                
                // Update order metrics
                document.getElementById('monthly-orders').textContent = 
                    data.monthly_orders || 0;
                
                // Update conversion rate
                document.getElementById('conversion-rate').textContent = 
                    `${(data.conversion_rate || 0).toFixed(2)}%`;

                // Update top products table
                const tbody = document.querySelector('#top-products tbody');
                tbody.innerHTML = ''; // Clear loading state
                
                if (data.top_products && data.top_products.length > 0) {
                    data.top_products.forEach(product => {
                        const row = document.createElement('tr');
                        row.innerHTML = `
                            <td>${product.name}</td>
                            <td>${product.units_sold}</td>
                            <td>${formatter.format(product.revenue)}</td>
                        `;
                        tbody.appendChild(row);
                    });
                } else {
                    const row = document.createElement('tr');
                    row.innerHTML = `
                        <td colspan="3" class="text-center">No data available</td>
                    `;
                    tbody.appendChild(row);
                }
            })
            .catch(error => {
                console.error('Error fetching realtime data:', error);
                const errorMessages = {
                    'today-revenue': 'Error',
                    'monthly-revenue': 'Error',
                    'monthly-orders': 'Error',
                    'conversion-rate': 'Error'
                };
                
                // Update UI elements with error state
                Object.keys(errorMessages).forEach(id => {
                    document.getElementById(id).textContent = errorMessages[id];
                });
                
                // Update table with error state
                const tbody = document.querySelector('#top-products tbody');
                tbody.innerHTML = `
                    <tr>
                        <td colspan="3" class="text-center text-danger">
                            Error loading data. Please try again later.
                        </td>
                    </tr>
                `;
            });
    }

    // Initial update
    updateMetrics();
    
    // Update every 30 seconds
    setInterval(updateMetrics, 30000);
});

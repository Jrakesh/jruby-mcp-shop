// Natural Language Analytics
const NLAnalytics = {
    init() {
    const Analytics = {
    // Only initialize if we're on the analytics page
    const nlQueryInput = document.getElementById('nlQuery');
    if (!nlQueryInput) return; // Exit if we're not on the analytics page
    
    const nlQuerySubmit = document.getElementById('nlQuerySubmit');
    const queryResult = document.getElementById('queryResult');
    const suggestions = document.querySelectorAll('.suggestion');

    // Handle query submission
    nlQuerySubmit.addEventListener('click', function() {
        submitNLQuery();
    });

    // Handle Enter key press
    nlQueryInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            submitNLQuery();
        }
    });

    // Handle suggestion clicks
    suggestions.forEach(suggestion => {
        suggestion.addEventListener('click', function(e) {
            e.preventDefault();
            nlQueryInput.value = this.getAttribute('data-query');
            submitNLQuery();
        });
    });

    function submitNLQuery() {
        const query = nlQueryInput.value.trim();
        if (!query) return;

        // Show loading state
        queryResult.innerHTML = `
            <div class="card">
                <div class="card-body">
                    <div class="d-flex align-items-center">
                        <div class="spinner-border text-primary me-3" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                        <span>Analyzing your query...</span>
                    </div>
                </div>
            </div>
        `;

        // Make API request
        fetch('/api/analyze', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ query: query })
        })
        .then(response => response.json())
        .then(data => {
            // Display results
            queryResult.innerHTML = `
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">Analysis Results</h5>
                        <div class="result-content">
                            ${formatResults(data)}
                        </div>
                    </div>
                </div>
            `;
        })
        .catch(error => {
            queryResult.innerHTML = `
                <div class="alert alert-danger">
                    Sorry, there was an error processing your query. Please try again.
                </div>
            `;
            console.error('Error:', error);
        });
    }

        // Create products table
    function createProductsTable(products) {
        return `
            <div class="card mb-4">
                <div class="card-body">
                    <h5 class="card-title">Top Selling Products</h5>
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>Product Name</th>
                                    <th>Revenue</th>
                                    <th>Units Sold</th>
                                    <th>Average Price</th>
                                </tr>
                            </thead>
                            <tbody>
                                ${products.map(product => `
                                    <tr>
                                        <td>${product.name}</td>
                                        <td>$${formatNumber(product.revenue)}</td>
                                        <td>${formatNumber(product.units_sold)}</td>
                                        <td>$${formatNumber(product.revenue / product.units_sold)}</td>
                                    </tr>
                                `).join('')}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        `;
    }

    // Helper function to format numbers
    function formatNumber(number) {
        return new Intl.NumberFormat('en-US', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        }).format(number);
    }
    
    // Create retention analysis chart
    function createRetentionAnalysis(data) {
        const chartId = 'retentionChart_' + Date.now();
        const html = `
            <div class="card mb-4">
                <div class="card-body">
                    <h5 class="card-title">Customer Retention Analysis</h5>
                    <div id="${chartId}" style="height: 400px;"></div>
                </div>
            </div>
        `;

        // Add HTML to DOM first
        document.getElementById('queryResult').insertAdjacentHTML('beforeend', html);

        // Initialize the chart
        const groupedData = {};
        data.forEach(p => {
            const count = p.order_count || 0;
            groupedData[count] = (groupedData[count] || 0) + 1;
        });

        const chart = new ApexCharts(document.getElementById(chartId), {
            series: [{
                name: 'Customers',
                data: Object.values(groupedData)
            }],
            chart: {
                type: 'bar',
                height: 350
            },
            plotOptions: {
                bar: {
                    borderRadius: 4,
                    horizontal: true,
                }
            },
            xaxis: {
                categories: Object.keys(groupedData).map(k => `${k} orders`)
            }
        });

        chart.render();
        return html;
    }

    // Create price sensitivity chart
    function createPriceSensitivityChart(data) {
        const chartId = 'priceSensitivityChart_' + Date.now();
        const html = `
            <div class="card mb-4">
                <div class="card-body">
                    <h5 class="card-title">Price Sensitivity Analysis</h5>
                    <div id="${chartId}" style="height: 400px;"></div>
                </div>
            </div>
        `;

        // Add HTML to DOM first
        document.getElementById('queryResult').insertAdjacentHTML('beforeend', html);

        // Initialize the chart
        const chart = new ApexCharts(document.getElementById(chartId), {
            series: [{
                name: 'Sales Volume',
                data: data.map(d => ({
                    x: d.price,
                    y: d.volume
                }))
            }],
            chart: {
                type: 'scatter',
                height: 350,
                zoom: {
                    enabled: true,
                    type: 'xy'
                }
            },
            xaxis: {
                title: { text: 'Price ($)' },
                tickAmount: 10
            },
            yaxis: {
                title: { text: 'Sales Volume' }
            },
            tooltip: {
                custom: function({series, seriesIndex, dataPointIndex, w}) {
                    const point = data[dataPointIndex];
                    return `
                        <div class="p-2">
                            <strong>Price: $${point.price}</strong><br/>
                            Volume: ${point.volume} units<br/>
                            Revenue: $${(point.price * point.volume).toFixed(2)}
                        </div>
                    `;
                }
            }
        });

        chart.render();
        return html;
    }

    function formatResults(data) {
        if (!data) {
            return `<div class="alert alert-warning">No data received from the server</div>`;
        }

        if (data.error) {
            return `<div class="alert alert-warning">${data.error}</div>`;
        }

        let resultHtml = '';
        
        try {
            // Handle multiple result types in the same response
            if (data.monthly_stats) {
                resultHtml += createMonthlyStatsChart(data.monthly_stats);
            }
            if (data.top_products) {
                resultHtml += createProductsTable(data.top_products);
            }
            if (data.spending_patterns) {
                resultHtml += createRetentionAnalysis(data.spending_patterns);
            }
            if (data.price_sensitivity) {
                resultHtml += createPriceSensitivityChart(data.price_sensitivity);
            }
            if (!resultHtml) {
                resultHtml = createGenericView(data);
            }
        } catch (error) {
            console.error('Error displaying results:', error);
            return `<div class="alert alert-danger">Error displaying results: ${error.message}</div>`;
        }
        
        return resultHtml || `<div class="alert alert-info">No matching data found for your query</div>`;
    }
    }

    function createMonthlyStatsChart(data) {
        const chartId = 'monthlyStatsChart_' + Date.now();
        const months = data.map(d => d.month);
        const revenue = data.map(d => d.revenue);
        const orders = data.map(d => d.order_count);

        // Return the HTML first
        const html = `
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title">Monthly Performance Analysis</h5>
                    <div id="${chartId}" class="chart-container"></div>
                </div>
            </div>
        `;

        // Initialize chart after the HTML is added to the DOM
        requestAnimationFrame(() => {
            const chartElement = document.getElementById(chartId);
            if (!chartElement) return;

            const options = {
                series: [{
                    name: 'Revenue',
                    type: 'column',
                    data: revenue
                }, {
                    name: 'Orders',
                    type: 'line',
                    data: orders
                }],
                chart: {
                    height: 350,
                    type: 'line',
                    stacked: false,
                    animations: {
                        enabled: true
                    },
                    fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif'
                },
                plotOptions: {
                    bar: {
                        columnWidth: '50%'
                    }
                },
                dataLabels: {
                    enabled: false
                },
                stroke: {
                    width: [1, 4]
                },
                title: {
                    text: 'Monthly Performance',
                    align: 'left',
                    style: {
                        fontSize: '16px',
                        fontWeight: 600
                    }
                },
                xaxis: {
                    categories: months,
                    labels: {
                        style: {
                            fontSize: '12px'
                        }
                    }
                },
                yaxis: [{
                    title: {
                        text: 'Revenue ($)',
                        style: {
                            fontSize: '13px'
                        }
                    },
                    labels: {
                        formatter: function(val) {
                            return '$' + val.toLocaleString();
                        },
                        style: {
                            fontSize: '12px'
                        }
                    }
                }, {
                    opposite: true,
                    title: {
                        text: 'Number of Orders',
                        style: {
                            fontSize: '13px'
                        }
                    },
                    labels: {
                        style: {
                            fontSize: '12px'
                        }
                    }
                }],
                tooltip: {
                    shared: true,
                    intersect: false,
                    y: [{
                        formatter: function(y) {
                            if (typeof y !== "undefined") {
                                return "$" + y.toFixed(0).replace(/\B(?=(\d{3})+(?!\d))/g, ",");
                            }
                            return y;
                        }
                    }, {
                        formatter: function(y) {
                            if (typeof y !== "undefined") {
                                return y.toFixed(0) + " orders";
                            }
                            return y;
                        }
                    }]
                },
                theme: {
                    mode: 'light',
                    palette: 'palette1'
                }
            };

            try {
                const chart = new ApexCharts(chartElement, options);
                chart.render();
            } catch (error) {
                console.error('Error rendering chart:', error);
                chartElement.innerHTML = '<div class="alert alert-danger">Error rendering chart</div>';
            }
        });

        return html;
    }

    function createProductsTable(products) {
        return `
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title">Top Selling Products</h5>
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>Product</th>
                                    <th>Units Sold</th>
                                    <th>Revenue</th>
                                </tr>
                            </thead>
                            <tbody>
                                ${products.map(p => `
                                    <tr>
                                        <td>${p.name}</td>
                                        <td>${p.units_sold.toLocaleString()}</td>
                                        <td>$${p.revenue.toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2})}</td>
                                    </tr>
                                `).join('')}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        `;
    }

    function createGenericView(data) {
        if (typeof data !== 'object') {
            return `<div class="alert alert-info">${data}</div>`;
        }

        const entries = Object.entries(data);
        if (entries.length === 0) {
            return `<div class="alert alert-warning">No data available</div>`;
        }

        return `
            <div class="card">
                <div class="card-body">
                    <h5 class="card-title">Analysis Results</h5>
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>Metric</th>
                                    <th>Value</th>
                                </tr>
                            </thead>
                            <tbody>
                                ${entries.map(([key, value]) => `
                                    <tr>
                                        <td>${formatHeader(key)}</td>
                                        <td>${formatValue(value)}</td>
                                    </tr>
                                `).join('')}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        `;
    }

    function createTable(data) {
        if (!data.length) return '<p>No data available</p>';

        const headers = Object.keys(data[0]);
        return `
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            ${headers.map(h => `<th>${formatHeader(h)}</th>`).join('')}
                        </tr>
                    </thead>
                    <tbody>
                        ${data.map(row => `
                            <tr>
                                ${headers.map(h => `<td>${formatValue(row[h])}</td>`).join('')}
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
            </div>
        `;
    }

    function createSummaryCards(data) {
        return Object.entries(data).map(([key, value]) => `
            <div class="card mb-3">
                <div class="card-body">
                    <h6 class="card-subtitle mb-2 text-muted">${formatHeader(key)}</h6>
                    <p class="card-text h4">${formatValue(value)}</p>
                </div>
            </div>
        `).join('');
    }

    function formatHeader(str) {
        return str.split('_')
            .map(word => word.charAt(0).toUpperCase() + word.slice(1))
            .join(' ');
    }

    function formatValue(value) {
        if (typeof value === 'number') {
            // Format as currency if it looks like a monetary value
            if (value > 100) {
                return new Intl.NumberFormat('en-US', {
                    style: 'currency',
                    currency: 'USD'
                }).format(value);
            }
            // Format as decimal if it's a small number
            return new Intl.NumberFormat('en-US', {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2
            }).format(value);
        }
        if (value instanceof Date) {
            return value.toLocaleDateString();
        }
        return value;
    }

    function createRetentionAnalysis(data) {
        const chartDiv = document.createElement('div');
        chartDiv.style.height = '400px';
        chartDiv.style.marginBottom = '20px';
        
        const retentionChart = new ApexCharts(chartDiv, {
            series: [{
                name: 'Customers',
                data: data.map(d => d.count)
            }],
            chart: {
                type: 'bar',
                height: 350
            },
            plotOptions: {
                bar: {
                    borderRadius: 4,
                    horizontal: true,
                }
            },
            xaxis: {
                categories: data.map(d => `${d.order_count} orders`)
            },
            title: {
                text: 'Customer Retention Analysis',
                align: 'center'
            }
        });
        
        retentionChart.render();
        
        return `
            <div class="mb-4">
                <h6 class="text-muted mb-3">Customer Retention Distribution</h6>
                ${chartDiv.outerHTML}
            </div>
        `;
    }

    function createPriceSensitivityChart(data) {
        const chartDiv = document.createElement('div');
        chartDiv.style.height = '400px';
        chartDiv.style.marginBottom = '20px';
        
        const priceChart = new ApexCharts(chartDiv, {
            series: [{
                name: 'Sales Volume',
                data: data.map(d => ({
                    x: d.price,
                    y: d.volume
                }))
            }],
            chart: {
                type: 'scatter',
                height: 350,
                zoom: {
                    enabled: true,
                    type: 'xy'
                }
            },
            xaxis: {
                title: { text: 'Price ($)' },
                tickAmount: 10
            },
            yaxis: {
                title: { text: 'Sales Volume' }
            },
            title: {
                text: 'Price Sensitivity Analysis',
                align: 'center'
            },
            tooltip: {
                custom: function({series, seriesIndex, dataPointIndex, w}) {
                    const point = data[dataPointIndex];
                    return `
                        <div class="p-2">
                            <strong>Price: $${point.price}</strong><br/>
                            Volume: ${point.volume} units<br/>
                            Revenue: $${(point.price * point.volume).toFixed(2)}
                        </div>
                    `;
                }
            }
        });
        
        priceChart.render();
        
        return `
            <div class="mb-4">
                <h6 class="text-muted mb-3">Price Sensitivity Analysis</h6>
                ${chartDiv.outerHTML}
                <p class="text-muted small mt-2">
                    Chart shows the relationship between price points and sales volume
                </p>
            </div>
        `;
    }
});

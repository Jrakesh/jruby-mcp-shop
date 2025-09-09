// Natural Language Analytics
const NLAnalytics = {
    init() {
        // Only initialize if we're on the analytics page
        const nlQueryInput = document.getElementById('nlQuery');
        if (!nlQueryInput) return; // Exit if we're not on the analytics page
    
        const nlQuerySubmit = document.getElementById('nlQuerySubmit');
        const queryResult = document.getElementById('queryResult');
        const suggestions = document.querySelectorAll('.suggestion');

        // Handle query submission
        nlQuerySubmit.addEventListener('click', () => this.submitNLQuery());

        // Handle Enter key press
        nlQueryInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                this.submitNLQuery();
            }
        });

        // Handle suggestion clicks
        suggestions.forEach(suggestion => {
            suggestion.addEventListener('click', (e) => {
                e.preventDefault();
                nlQueryInput.value = suggestion.getAttribute('data-query');
                this.submitNLQuery();
            });
        });
    },

    async submitNLQuery() {
        const nlQueryInput = document.getElementById('nlQuery');
        const queryResult = document.getElementById('queryResult');
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

        try {
            // Make API request
            const response = await fetch('/api/analyze', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ query })
            });
            
            const data = await response.json();
            // Display results
            queryResult.innerHTML = `
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">Analysis Results</h5>
                        <div class="result-content">
                            ${this.formatResults(data)}
                        </div>
                    </div>
                </div>
            `;
        } catch (error) {
            console.error('Error:', error);
            queryResult.innerHTML = `
                <div class="alert alert-danger">
                    Sorry, there was an error processing your query. Please try again.
                </div>
            `;
        }
    },

    formatResults(data) {
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
                resultHtml += this.createMonthlyStatsChart(data.monthly_stats);
            }
            if (data.top_products) {
                resultHtml += this.createProductsTable(data.top_products);
            }
            if (data.spending_patterns) {
                resultHtml += this.createRetentionAnalysis(data.spending_patterns);
            }
            // Fix: Handle the correct retention_data key
            if (data.retention_data) {
                resultHtml += this.createRetentionAnalysis(data.retention_data);
            }
            if (data.price_sensitivity) {
                resultHtml += this.createPriceSensitivityChart(data.price_sensitivity);
            }
            if (!resultHtml) {
                resultHtml = this.createGenericView(data);
            }
        } catch (error) {
            console.error('Error formatting results:', error);
            return `<div class="alert alert-danger">Error displaying results: ${error.message}</div>`;
        }
        
        return resultHtml || `<div class="alert alert-info">No matching data found for your query</div>`;
    },

    createMonthlyStatsChart(data) {
        const chartId = 'monthlyStatsChart_' + Date.now();
        const html = `
            <div class="card mb-4">
                <div class="card-body">
                    <h5 class="card-title">Monthly Performance Analysis</h5>
                    <div id="${chartId}" style="height: 400px;"></div>
                </div>
            </div>
        `;

        setTimeout(() => {
            const chartElement = document.getElementById(chartId);
            if (!chartElement) return;

            const options = {
                series: [{
                    name: 'Revenue',
                    type: 'column',
                    data: data.map(d => d.revenue || 0)
                }, {
                    name: 'Orders',
                    type: 'line',
                    data: data.map(d => d.order_count || 0)
                }],
                chart: {
                    height: 350,
                    type: 'line',
                    stacked: false
                },
                xaxis: {
                    categories: data.map(d => d.month || 'Unknown')
                },
                yaxis: [{
                    title: { text: 'Revenue ($)' }
                }, {
                    opposite: true,
                    title: { text: 'Orders' }
                }]
            };

            try {
                const chart = new ApexCharts(chartElement, options);
                chart.render();
            } catch (error) {
                console.error('Error rendering monthly stats chart:', error);
                chartElement.innerHTML = '<div class="alert alert-danger">Error rendering chart</div>';
            }
        }, 100);

        return html;
    },

    createRetentionAnalysis(data) {
        const chartId = 'retentionChart_' + Date.now();
        const html = `
            <div class="card mb-4">
                <div class="card-body">
                    <h5 class="card-title">Customer Retention Analysis</h5>
                    <div id="${chartId}" style="height: 400px;"></div>
                </div>
            </div>
        `;

        setTimeout(() => {
            const chartElement = document.getElementById(chartId);
            if (!chartElement) return;

            const groupedData = {};
            if (Array.isArray(data)) {
                data.forEach(p => {
                    const count = p.order_count || 0;
                    groupedData[count] = (groupedData[count] || 0) + 1;
                });
            }

            const chartData = Object.values(groupedData);
            const chartLabels = Object.keys(groupedData).map(k => `${k} orders`);

            if (chartData.length === 0) {
                chartElement.innerHTML = '<div class="alert alert-info">No retention data available</div>';
                return;
            }

            const options = {
                series: [{
                    name: 'Customers',
                    data: chartData
                }],
                chart: {
                    type: 'bar',
                    height: 350
                },
                plotOptions: {
                    bar: {
                        horizontal: true,
                        borderRadius: 4
                    }
                },
                xaxis: {
                    categories: chartLabels
                },
                title: {
                    text: 'Customer Order Distribution',
                    align: 'center'
                },
                colors: ['#008FFB']
            };

            try {
                const chart = new ApexCharts(chartElement, options);
                chart.render();
            } catch (error) {
                console.error('Error rendering retention chart:', error);
                chartElement.innerHTML = '<div class="alert alert-danger">Error rendering retention chart</div>';
            }
        }, 100);

        return html;
    },

    createProductsTable(products) {
        if (!Array.isArray(products) || products.length === 0) {
            return `
                <div class="card mb-4">
                    <div class="card-body">
                        <h5 class="card-title">Top Selling Products</h5>
                        <div class="alert alert-info">No product data available</div>
                    </div>
                </div>
            `;
        }

        const chartId = 'productsChart_' + Date.now();
        const html = `
            <div class="row">
                <div class="col-md-6 mb-4">
                    <div class="card">
                        <div class="card-body">
                            <h5 class="card-title">Top Products by Revenue</h5>
                            <div id="${chartId}" style="height: 400px;"></div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6 mb-4">
                    <div class="card">
                        <div class="card-body">
                            <h5 class="card-title">Product Details</h5>
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
                                                <td>${p.name || 'Unknown Product'}</td>
                                                <td>${this.formatNumber(p.units_sold || 0)}</td>
                                                <td>${this.formatCurrency(p.revenue || 0)}</td>
                                            </tr>
                                        `).join('')}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        `;

        setTimeout(() => {
            const chartElement = document.getElementById(chartId);
            if (!chartElement) return;

            const options = {
                series: [{
                    name: 'Revenue',
                    data: products.map(p => p.revenue || 0)
                }],
                chart: {
                    type: 'bar',
                    height: 350
                },
                plotOptions: {
                    bar: {
                        borderRadius: 4,
                        horizontal: false,
                    }
                },
                dataLabels: {
                    enabled: false
                },
                xaxis: {
                    categories: products.map(p => p.name || 'Unknown'),
                    labels: {
                        rotate: -45,
                        maxHeight: 120
                    }
                },
                yaxis: {
                    title: {
                        text: 'Revenue ($)'
                    },
                    labels: {
                        formatter: function (val) {
                            return '$' + val.toLocaleString();
                        }
                    }
                },
                title: {
                    text: 'Revenue by Product',
                    align: 'center'
                },
                colors: ['#00E396'],
                tooltip: {
                    y: {
                        formatter: function (val) {
                            return '$' + val.toLocaleString();
                        }
                    }
                }
            };

            try {
                const chart = new ApexCharts(chartElement, options);
                chart.render();
            } catch (error) {
                console.error('Error rendering products chart:', error);
                chartElement.innerHTML = '<div class="alert alert-danger">Error rendering chart</div>';
            }
        }, 100);

        return html;
    },

    createPriceSensitivityChart(data) {
        const chartId = 'sensitivityChart_' + Date.now();
        const html = `
            <div class="row">
                <div class="col-md-8 mb-4">
                    <div class="card">
                        <div class="card-body">
                            <h5 class="card-title">Price vs Volume Analysis</h5>
                            <div id="${chartId}" style="height: 400px;"></div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 mb-4">
                    <div class="card">
                        <div class="card-body">
                            <h5 class="card-title">Price Categories</h5>
                            <div class="table-responsive">
                                <table class="table table-sm">
                                    <thead>
                                        <tr>
                                            <th>Product</th>
                                            <th>Price</th>
                                            <th>Volume</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        ${data.map(d => `
                                            <tr>
                                                <td>${d.name || 'Unknown'}</td>
                                                <td>${this.formatCurrency(d.price || 0)}</td>
                                                <td>${this.formatNumber(d.volume || 0)}</td>
                                            </tr>
                                        `).join('')}
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        `;

        setTimeout(() => {
            const chartElement = document.getElementById(chartId);
            if (!chartElement || !Array.isArray(data) || data.length === 0) {
                if (chartElement) {
                    chartElement.innerHTML = '<div class="alert alert-info">No price sensitivity data available</div>';
                }
                return;
            }

            console.log('Price sensitivity data:', data); // Debug log

            const options = {
                series: [{
                    name: 'Products',
                    data: data.map(d => ({
                        x: d.price || 0,
                        y: d.volume || 0,
                        name: d.name || 'Unknown Product'
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
                    title: { 
                        text: 'Price ($)',
                        style: {
                            fontSize: '14px',
                            fontWeight: 600
                        }
                    },
                    labels: {
                        formatter: function (val) {
                            return '$' + val.toFixed(0);
                        }
                    }
                },
                yaxis: {
                    title: { 
                        text: 'Sales Volume (Units)',
                        style: {
                            fontSize: '14px',
                            fontWeight: 600
                        }
                    }
                },
                tooltip: {
                    custom: function({ series, seriesIndex, dataPointIndex, w }) {
                        const point = data[dataPointIndex];
                        return `
                            <div class="p-3">
                                <strong>${point.name}</strong><br/>
                                Price: ${new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(point.price)}<br/>
                                Volume: ${point.volume} units<br/>
                                Category: ${point.price_category || 'N/A'}
                            </div>
                        `;
                    }
                },
                colors: ['#FF4560'],
                markers: {
                    size: 6,
                    hover: {
                        size: 8
                    }
                },
                grid: {
                    borderColor: '#e7e7e7',
                    row: {
                        colors: ['#f3f3f3', 'transparent'],
                        opacity: 0.5
                    }
                }
            };

            try {
                const chart = new ApexCharts(chartElement, options);
                chart.render();
            } catch (error) {
                console.error('Error rendering price sensitivity chart:', error);
                chartElement.innerHTML = '<div class="alert alert-danger">Error rendering chart: ' + error.message + '</div>';
            }
        }, 100);

        return html;
    },

    createGenericView(data) {
        return `
            <div class="card mb-4">
                <div class="card-body">
                    <h5 class="card-title">Analysis Results</h5>
                    <pre class="bg-light p-3">${JSON.stringify(data, null, 2)}</pre>
                </div>
            </div>
        `;
    },

    formatNumber(number) {
        return new Intl.NumberFormat('en-US').format(number || 0);
    },

    formatCurrency(amount) {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD'
        }).format(amount || 0);
    }
};

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => NLAnalytics.init());

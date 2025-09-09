document.addEventListener('DOMContentLoaded', function() {
    console.log('[DEBUG] Starting chart initialization...');
    
    // Verify analytics data exists
    if (!window.analyticsData) {
        console.error('Analytics data is missing');
        return;
    }
    
    const { monthlyStats, topProducts, salesTrends, inventory, customerPatterns } = window.analyticsData;
    // Remove realtime data references
    delete window.analyticsData.realtime;
    console.log('[DEBUG] Analytics Data:', window.analyticsData);
    
    try {
        // Monthly Revenue Chart
        const revenueCtx = document.getElementById('revenueChart');
        if (revenueCtx && monthlyStats && monthlyStats.monthly_stats) {
            console.log('[DEBUG] Initializing Monthly Revenue Chart...');
            new Chart(revenueCtx.getContext('2d'), {
                type: 'bar',
                data: {
                    labels: monthlyStats.monthly_stats.map(s => s.month),
                    datasets: [{
                        label: 'Monthly Revenue',
                        data: monthlyStats.monthly_stats.map(s => s.revenue),
                        backgroundColor: 'rgba(54, 162, 235, 0.5)'
                    }]
                },
                options: {
                    responsive: true,
                    scales: { y: { beginAtZero: true } }
                }
            });
        }

        // Top Products Chart
        const topProductsEl = document.getElementById('topProductsChart');
        if (topProductsEl && topProducts && topProducts.top_products) {
            console.log('[DEBUG] Initializing Top Products Chart...');
            const chart = new ApexCharts(topProductsEl, {
                series: [{
                    name: 'Units Sold',
                    data: topProducts.top_products.map(p => p.units_sold)
                }],
                chart: { type: 'bar', height: 350 },
                xaxis: {
                    categories: topProducts.top_products.map(p => p.name)
                }
            });
            chart.render();
        }

        // Sales Trend Chart
        const salesTrendCtx = document.getElementById('salesTrendChart');
        if (salesTrendCtx && salesTrends && salesTrends.daily_trends) {
            console.log('[DEBUG] Initializing Sales Trend Chart...');
            new Chart(salesTrendCtx.getContext('2d'), {
                type: 'line',
                data: {
                    labels: salesTrends.daily_trends.map(t => t.date),
                    datasets: [{
                        label: 'Daily Revenue',
                        data: salesTrends.daily_trends.map(t => t.revenue),
                        borderColor: 'rgb(75, 192, 192)',
                        tension: 0.1
                    }]
                },
                options: { responsive: true }
            });
        }

        // Inventory Status Chart
        const inventoryChartEl = document.getElementById('inventoryChart');
        if (inventoryChartEl && inventory && inventory.alerts) {
            console.log('[DEBUG] Initializing Inventory Chart...');
            const chart = new ApexCharts(inventoryChartEl, {
                series: inventory.alerts.map(a => a.stock_level),
                chart: {
                    type: 'donut',
                    height: 350
                },
                labels: inventory.alerts.map(a => a.product)
            });
            chart.render();
        }

        // Customer Spending Patterns Chart
        const spendingChartEl = document.getElementById('spendingPatternsChart');
        if (spendingChartEl && customerPatterns && customerPatterns.spending_patterns) {
            console.log('[DEBUG] Initializing Customer Spending Chart...');
            const chart = new ApexCharts(spendingChartEl, {
                series: [{
                    name: 'Average Order Value',
                    data: customerPatterns.spending_patterns.map(p => p.average_order)
                }, {
                    name: 'Total Spent',
                    data: customerPatterns.spending_patterns.map(p => p.total_spent)
                }],
                chart: {
                    type: 'bar',
                    height: 350,
                    stacked: true
                },
                xaxis: {
                    categories: customerPatterns.spending_patterns.map(p => p.email)
                }
            });
            chart.render();
        }
    } catch (error) {
        console.error('[ERROR] Failed to initialize charts:', error);
    }
});

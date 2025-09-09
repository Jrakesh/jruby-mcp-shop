// Advanced Charts Module
(function(window) {
    'use strict';

    // Debug flag for development
    const DEBUG = true;

    // Logging functions
    function debug(...args) {
        if (DEBUG) {
            console.log('[Advanced Charts]', ...args);
        }
    }

    function error(...args) {
        console.error('[Advanced Charts]', ...args);
    }

    // Verify required libraries
    function verifyDependencies() {
        if (typeof ApexCharts === 'undefined') {
            error('ApexCharts is not loaded. Please include the ApexCharts library.');
            return false;
        }
        return true;
    }

    // Function to safely initialize chart
    function initializeChart(elementId, chartConfig) {
        debug('Initializing chart:', elementId);
        
        if (!elementId || !chartConfig) {
            error('Missing required parameters for chart initialization');
            return null;
        }

        const element = document.querySelector(elementId);
        if (!element) {
            error(`Element ${elementId} not found`);
            return null;
        }

        if (!verifyDependencies()) {
            return null;
        }

        // Ensure basic chart configuration
        const defaultConfig = {
            chart: {
                animations: {
                    enabled: true,
                    easing: 'easeinout',
                    speed: 800
                },
                toolbar: {
                    show: true
                }
            },
            tooltip: {
                enabled: true
            }
        };

        const finalConfig = { ...defaultConfig, ...chartConfig };

        try {
            debug(`Creating chart with config:`, finalConfig);
            const chart = new ApexCharts(element, finalConfig);
            chart.render();
            debug(`Chart ${elementId} rendered successfully`);
            return chart;
        } catch (err) {
            error(`Error initializing chart ${elementId}:`, err);
            return null;
        }
    }

    // Main chart initialization function
    function initializeCharts(data) {
        debug('Starting chart initialization with data:', data);
        
        if (!data) {
            error('No data provided for charts');
            return;
        }
        
        if (!verifyDependencies()) {
            return;
        }

        // Clean up any existing charts
        document.querySelectorAll('.chart-container').forEach(container => {
            container.innerHTML = '';
        });

        // Revenue Overview Chart
        if (data.revenue?.length > 0) {
            debug('Initializing revenue chart');
            initializeChart("#revenueChart", {
                series: [{
                    name: 'Revenue',
                    data: data.revenue.map(d => d.revenue)
                }, {
                    name: 'Orders',
                    data: data.revenue.map(d => d.order_count)
                }],
                chart: {
                    type: 'area',
                    height: 350
                },
                stroke: { curve: 'smooth' },
                fill: {
                    type: 'gradient',
                    gradient: {
                        shadeIntensity: 1,
                        opacityFrom: 0.7,
                        opacityTo: 0.3
                    }
                },
                xaxis: {
                    categories: data.revenue.map(d => d.month)
                }
            });
        }

        // Product Performance Matrix
        if (data.products?.length > 0) {
            debug('Initializing product matrix');
            initializeChart("#productMatrix", {
                series: [{
                    name: 'Revenue',
                    data: data.products.map(d => ({
                        x: d.units_sold,
                        y: d.revenue,
                        name: d.name
                    }))
                }],
                chart: {
                    type: 'scatter',
                    height: 350,
                    zoom: { enabled: true }
                },
                xaxis: { title: { text: 'Units Sold' } },
                yaxis: { title: { text: 'Revenue' } },
                tooltip: {
                    custom: function({ seriesIndex, dataPointIndex, w }) {
                        const point = data.products[dataPointIndex];
                        return `
                            <div class="p-2">
                                <strong>${point.name}</strong><br/>
                                Revenue: $${point.revenue.toLocaleString()}<br/>
                                Units: ${point.units_sold}
                            </div>
                        `;
                    }
                }
            });
        }

        // Category Distribution
        if (data.categories?.length > 0) {
            debug('Initializing category treemap');
            initializeChart("#categoryTreemap", {
                series: [{
                    data: data.categories.map(c => ({
                        x: c.name,
                        y: c.revenue
                    }))
                }],
                chart: {
                    type: 'treemap',
                    height: 350
                },
                tooltip: {
                    y: {
                        formatter: val => '$' + val.toLocaleString()
                    }
                }
            });
        }

        // Seasonal Patterns
        if (data.seasonal && data.seasonal.length > 0) {
            initializeChart("#seasonalRadar", {
                series: [{
                    name: 'Sales',
                    data: data.seasonal.map(d => d.total_sales)
                }],
                chart: {
                    type: 'radar',
                    height: 350
                },
                xaxis: {
                    categories: data.seasonal.map(d => `${d.month}/${d.year}`)
                }
            });
        }

        // Customer Retention
        if (data.retention && data.retention.length > 0) {
            initializeChart("#retentionFunnel", {
                series: [{
                    name: 'Customers',
                    data: data.retention.map(d => d.order_count)
                }],
                chart: {
                    type: 'bar',
                    height: 350
                },
                plotOptions: {
                    bar: { horizontal: true }
                },
                xaxis: {
                    categories: data.retention.map(d => d.email)
                }
            });
        }

        // Product Affinity Network
        if (data.affinity && data.affinity.length > 0 && typeof vis !== 'undefined') {
            const networkContainer = document.querySelector("#affinityNetwork");
            if (networkContainer) {
                try {
                    const nodes = [...new Set(data.affinity.flatMap(d => d.categories))].map(category => ({
                        id: category,
                        label: category
                    }));
                    
                    const edges = data.affinity.map(d => ({
                        from: d.categories[0],
                        to: d.categories[1],
                        value: d.frequency,
                        title: `Frequency: ${d.frequency}`
                    }));

                    new vis.Network(networkContainer, { nodes, edges }, {
                        nodes: {
                            shape: 'dot',
                            scaling: { min: 10, max: 30 }
                        },
                        edges: {
                            scaling: { min: 1, max: 3 }
                        },
                        physics: {
                            stabilization: true,
                            barnesHut: {
                                gravitationalConstant: -2000,
                                springConstant: 0.04
                            }
                        }
                    });
                } catch (error) {
                    console.error('Error initializing affinity network:', error);
                }
            }
        }

        // Spending Patterns
        if (data.patterns && data.patterns.length > 0) {
            initializeChart("#spendingPatternsChart", {
                series: [{
                    name: 'Total Spent',
                    data: data.patterns.map(d => d.total_spent)
                }],
                chart: {
                    type: 'bar',
                    height: 350
                },
                xaxis: {
                    categories: data.patterns.map(d => d.email)
                },
                tooltip: {
                    y: {
                        formatter: val => '$' + val.toLocaleString()
                    }
                }
            });
        }

    }

    // Export public interface
    window.AdvancedCharts = {
        initialize: initializeCharts,
        initializeChart: initializeChart
    };

})(window);

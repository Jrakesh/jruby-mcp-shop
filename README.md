# JRuby MCP Shop

A modern e-commerce platform built with JRuby and powered by Model Context Protocol (MCP), combining the flexibility of Ruby with the robustness of the Java ecosystem. Features AI-powered travel search capabilities with real-time data integration.

## 🌟 Features

### Advanced Analytics Dashboard
- **Real-time business insights** with interactive charts using ApexCharts
- **Customer spending pattern analysis** with detailed segmentation
- **Product performance metrics** with revenue tracking
- **Sales trend analysis** with time-series data
- **Inventory management dashboards** with predictive analytics
- **MCP-powered natural language queries** for business intelligence

### AI-Powered Travel & Hospitality Integration
- **Hotels & Restaurants Search**: 
  - Real-time search powered by SerpAPI for accurate, up-to-date results
  - Comprehensive coverage of 300+ Indian cities and major international destinations
  - Detailed information including ratings, reviews, pricing, and contact details
  - Smart location mapping with GPS coordinates for precise results

- **Flight Search**: 
  - Live flight data from multiple airlines via SerpAPI integration
  - Support for both domestic Indian and international routes
  - Round-trip and one-way search options with flexible date selection
  - Multiple passenger and travel class options
  - Real-time pricing and availability updates

### Fast-MCP Gem Integration
- **High-performance MCP implementation** using the fast-mcp gem
- **Natural language processing** for business queries
- **Context-aware data processing** with intelligent relationship mapping
- **Automated insights generation** from complex business data
- **Cross-referential analytics** linking orders, products, and customer behavior

### Technical Architecture
- **JRuby 2.5.7** runtime with Java interoperability
- **Sinatra web framework** with HAML templating
- **PostgreSQL database** with Sequel ORM
- **Bootstrap 5.1.3** responsive UI framework
- **ApexCharts** for interactive data visualization
- **SerpAPI integration** for real-time search capabilities
- **Fast-MCP gem** for Model Context Protocol implementation

## 🚀 MCP Integration Highlights

### Natural Language Analytics
Ask questions in plain English using the fast-mcp gem:
- "Show me top selling products this month"
- "What's the customer retention rate for Q2?"
- "Analyze price sensitivity for electronics category"
- "Compare revenue trends between regions"
- "Find customers with highest lifetime value"

### Contextual Intelligence
- **Smart data correlation** across orders, products, and customers
- **Intelligent pattern recognition** in sales and behavior data
- **Automated insight discovery** with MCP-powered analysis
- **Self-improving query understanding** through contextual learning
- **Cross-domain analytics** linking e-commerce and travel data

## 🌏 Travel Features Powered by SerpAPI

### Hotels & Restaurants Search
- **Real-time data** from Google Maps via SerpAPI
- **Comprehensive Indian coverage**: Mumbai, Delhi, Bangalore, Chennai, Kolkata, Hyderabad, Pune, and 290+ more cities
- **Global destinations**: New York, London, Paris, Tokyo, Dubai, Singapore, and major international cities
- **Detailed information**: Ratings, reviews, pricing, contact details, operating hours
- **Smart filtering**: By type (hotels, restaurants, cafes), price range, and ratings

### Flight Search Integration
- **Live flight data** from Google Flights via SerpAPI
- **Comprehensive airport coverage**: 100+ Indian airports including all major hubs
- **International connectivity**: Major global airports and routes
- **Advanced search options**: 
  - Flexible date selection with calendar integration
  - Multiple passenger support (adults, children, infants)
  - Travel class selection (Economy, Premium Economy, Business, First)
  - Round-trip and one-way journey options
- **Real-time updates**: Live pricing, availability, and schedule changes

### SerpAPI Technical Implementation
- **Robust error handling** with graceful fallback to demo data
- **Timeout management** (10-second timeout) for optimal performance
- **Comprehensive location mapping** with GPS coordinates
- **Smart airport code resolution** for accurate flight searches
- **Rate limiting compliance** with SerpAPI best practices

### Hotels & Restaurants
- Search accommodations and dining in any city
- Real ratings, reviews, and pricing
- Contact information and hours
- Coverage for 300+ Indian cities
- International destinations supported

### Flight Search
- Compare flights from major airlines
- Real-time pricing and availability
- Support for Indian domestic and international routes
- Round-trip and one-way options
- Multiple passenger and class options

### Supported Locations
- **India**: Mumbai, Delhi, Bangalore, Chennai, Kolkata, Hyderabad, Pune, and 200+ more
- **International**: New York, London, Paris, Tokyo, Dubai, Singapore, and major global cities

## 🔮 Future Possibilities

### Integration Capabilities with Fast-MCP
- **Machine Learning Model Integration** - Direct integration with TensorFlow and PyTorch models
- **Voice Commerce Integration** - Speech-to-text processing for voice-based orders
- **Social Commerce Analytics** - Social media sentiment analysis and trend detection
- **IoT Device Data Processing** - Real-time data from smart retail devices

### Advanced MCP Features
- **Predictive Inventory Management** - AI-powered stock level optimization
- **Personalized Customer Journeys** - Dynamic user experience customization
- **Real-time Market Adaptation** - Automated pricing and inventory adjustments
- **Automated Business Insights** - Self-generating reports and recommendations

### SerpAPI Enhancements
- **Multi-source data aggregation** - Combining multiple travel data sources
- **Price tracking and alerts** - Automated monitoring of hotel and flight prices
- **Seasonal trend analysis** - Historical data analysis for pricing patterns
- **Custom location intelligence** - Enhanced geo-spatial search capabilities

## 🏗 Architecture Overview

### Technology Stack
```
Frontend Layer:
├── Bootstrap 5.1.3 (Responsive UI)
├── ApexCharts (Data Visualization)
├── HAML Templates (Clean HTML generation)
└── JavaScript (Interactive features)

Application Layer:
├── JRuby 2.5.7 (Ruby on JVM)
├── Sinatra (Web Framework)
├── Fast-MCP Gem (Model Context Protocol)
└── Sequel ORM (Database abstraction)

Integration Layer:
├── SerpAPI (Travel search)
├── PostgreSQL (Primary database)
└── RESTful APIs (Data exchange)

Infrastructure:
├── Java Virtual Machine
├── Puma Web Server
└── Rack Middleware
```

### MCP Implementation Details
The fast-mcp gem provides:
- **High-performance native bindings** for optimal processing speed
- **Memory-efficient context management** for large datasets
- **Concurrent query processing** for multiple simultaneous requests
- **Advanced caching mechanisms** for frequently accessed patterns
- **Extensible plugin architecture** for custom analytics modules

## 🔒 Security & Best Practices

### Security Features
- **SQL injection protection** through Sequel ORM parameterized queries
- **Cross-site scripting (XSS) prevention** with HAML auto-escaping
- **API key security** with environment variable management
- **Request validation** for all external API calls
- **Error handling** that doesn't expose internal system details

### Performance Optimizations
- **Database connection pooling** for efficient resource utilization
- **Caching strategies** for frequently accessed data
- **Lazy loading** for large datasets
- **Optimized JSON serialization** for API responses
- **Background job processing** for heavy computational tasks

### Monitoring & Observability
```ruby
# Built-in logging and monitoring
Logger.info "SerpAPI request: #{search_params}"
Logger.error "Search failed: #{e.message}" if error

# Performance tracking
response_time = Benchmark.measure do
  result = serpapi_service.search_hotels_restaurants(location)
end
```

## 🛠 Setup and Installation

### Prerequisites
- **JRuby 9.3.0 or higher** (currently tested with JRuby 2.5.7)
- **Java Development Kit (JDK) 11 or higher**
- **Bundler gem** for dependency management
- **PostgreSQL database** (version 12 or higher recommended)
- **SerpAPI key** for travel search functionality (optional - falls back to demo data)

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone [repository-url]
   cd jruby-ecommerce-mcp
   ```

2. **Install dependencies:**
   ```bash
   bundle install
   ```

3. **Configure the database:**
   ```bash
   cp config/config.yml.example config/config.yml
   # Edit config.yml with your database credentials
   bundle exec rake db:setup
   ```

4. **Set up SerpAPI (optional):**
   ```bash
   cp .env.example .env
   # Edit .env and add your SerpAPI key:
   # SERPAPI_API_KEY=your_actual_serpapi_key_here
   ```

5. **Start the server:**
   ```bash
   # Development mode
   bundle exec ruby app.rb -p 3000
   
   # Or use the provided script
   ./start_server.sh
   ```

6. **Run tests:**
   ```bash
   # Run all tests
   bundle exec rake test
   
   # Run specific test file
   bundle exec ruby test/test_application.rb
   ```

## 🧪 Testing

### Test Suite
The application includes comprehensive unit tests covering:

- **Application endpoints** - All routes and API endpoints
- **SerpAPI service** - Search functionality and data formatting
- **Model operations** - Database interactions and validations
- **Integration tests** - Full request/response cycles

### Running Tests
```bash
# Run all tests
bundle exec rake test

# Run specific test categories
bundle exec ruby test/test_application.rb    # Application tests
bundle exec ruby test/test_serpapi_service.rb # SerpAPI tests
bundle exec ruby test/test_models.rb         # Model tests

# Run tests with verbose output
bundle exec rake test TESTOPTS="-v"
```

### Test Configuration
Tests use:
- **Minitest** framework for unit testing
- **Rack::Test** for HTTP request testing
- **Test environment** with isolated test data
- **Automatic cleanup** after each test run

## 📚 API Documentation

### MCP Query Examples with Fast-MCP Gem

```ruby
# Natural language business intelligence queries
# (These would be processed by the fast-mcp gem integration)

# Revenue analysis
"Show me revenue trends for the last 6 months"
"Which products generated the most profit in Q3?"

# Customer insights
"Identify customers with declining purchase frequency"
"Show customer lifetime value distribution"

# Inventory management
"Predict inventory needs for electronics category next month"
"Alert me about products with low stock levels"

# Complex analytical queries
"Compare customer retention rates between different regions"
"Analyze correlation between marketing campaigns and sales"
```

### REST API Endpoints

```bash
# Analytics Data
GET  /api/analytics/data              # Get dashboard analytics
GET  /api/products                    # Get all products
GET  /api/orders                      # Get all orders

# Travel Search APIs
POST /api/search/hotels-restaurants   # Search hotels and restaurants
POST /api/search/flights              # Search flights

# Example requests:
curl -X POST http://localhost:3000/api/search/hotels-restaurants \
  -H "Content-Type: application/json" \
  -d '{"location": "Mumbai", "query_type": "hotels"}'

curl -X POST http://localhost:3000/api/search/flights \
  -H "Content-Type: application/json" \
  -d '{
    "origin": "Mumbai", 
    "destination": "Delhi", 
    "departure_date": "2025-12-01",
    "passengers": 2
  }'
```

## 🔧 Configuration

### Environment Variables
```bash
# Database configuration
DATABASE_URL=postgresql://user:password@localhost/jruby_mcp_shop

# SerpAPI configuration  
SERPAPI_API_KEY=your_serpapi_key_here

# Application settings
RACK_ENV=production
PORT=3000
```

### Fast-MCP Integration
The application uses the fast-mcp gem for:
- **High-performance MCP processing** with optimized Ruby bindings
- **Natural language query parsing** for business intelligence
- **Context-aware data analysis** across multiple data sources
- **Real-time insight generation** from complex datasets

## 🔒 Security

- Built-in protection against SQL injection through MCP query parsing
- Role-based access control
- Data encryption at rest
- Secure API endpoints

## 🔄 Development Workflow

1. Create a new branch for your feature
2. Write tests for your changes
3. Implement your changes
4. Run the test suite
5. Submit a pull request

## 📊 Monitoring and Maintenance

- Built-in error tracking
- Performance monitoring
- Automated backups
- Regular security updates

## 📝 License

MIT License - See LICENSE file for details

## 👥 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## 📧 Support

For support and queries, please create an issue in the repository or contact the development team.

---

Built with ❤️ using JRuby and Model Context Protocol

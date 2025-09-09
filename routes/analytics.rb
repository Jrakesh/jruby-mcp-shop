# Analytics routes
class EcommerceApp < Sinatra::Base
  get '/analytics' do
    @mcp = EcommerceMCP.new(settings.database)
    
    # Gather all analytics data
    @monthly_stats = @mcp.handle_query("monthly orders")
    @top_products = @mcp.handle_query("top selling products")
    @sales_trends = @mcp.handle_query("sales trends")
    @inventory = @mcp.handle_query("inventory alerts")
    @customer_patterns = @mcp.handle_query("customer spending patterns")
    
    haml :analytics
  end

  get '/advanced_analytics' do
    @mcp = EcommerceMCP.new(settings.database)
    
    begin
      # Gather all analytics data
      @monthly_stats = @mcp.handle_query("monthly orders")
      @top_products = @mcp.handle_query("top selling products")
      @sales_trends = @mcp.handle_query("sales trends")
      @customer_patterns = @mcp.handle_query("customer spending patterns")

      # Provide sample data if any of the real data is empty
      if @monthly_stats.nil? || @monthly_stats[:monthly_stats].empty?
        @monthly_stats = {
          monthly_stats: [
            { month: 'Jan', revenue: 150000, order_count: 1200 },
            { month: 'Feb', revenue: 165000, order_count: 1350 },
            { month: 'Mar', revenue: 180000, order_count: 1500 },
            { month: 'Apr', revenue: 172000, order_count: 1420 },
            { month: 'May', revenue: 195000, order_count: 1600 }
          ]
        }
      end

      if @top_products.nil? || @top_products[:top_products].empty?
        @top_products = {
          top_products: [
            { name: 'Product A', revenue: 50000, units_sold: 500, category: 'Electronics' },
            { name: 'Product B', revenue: 45000, units_sold: 300, category: 'Clothing' },
            { name: 'Product C', revenue: 40000, units_sold: 400, category: 'Home' },
            { name: 'Product D', revenue: 35000, units_sold: 250, category: 'Electronics' },
            { name: 'Product E', revenue: 30000, units_sold: 200, category: 'Accessories' }
          ]
        }
      end

      if @sales_trends.nil? || @sales_trends[:daily_trends].empty?
        @sales_trends = {
          daily_trends: [
            { date: 'Mon', revenue: 25000 },
            { date: 'Tue', revenue: 28000 },
            { date: 'Wed', revenue: 32000 },
            { date: 'Thu', revenue: 30000 },
            { date: 'Fri', revenue: 35000 },
            { date: 'Sat', revenue: 40000 },
            { date: 'Sun', revenue: 22000 }
          ]
        }
      end

      if @customer_patterns.nil? || @customer_patterns[:spending_patterns].empty?
        @customer_patterns = {
          spending_patterns: [
            { email: 'customer1@example.com', order_count: 5, average_order: 200, total_spent: 1000 },
            { email: 'customer2@example.com', order_count: 3, average_order: 150, total_spent: 450 },
            { email: 'customer3@example.com', order_count: 8, average_order: 175, total_spent: 1400 },
            { email: 'customer4@example.com', order_count: 2, average_order: 300, total_spent: 600 },
            { email: 'customer5@example.com', order_count: 6, average_order: 250, total_spent: 1500 }
          ]
        }
      end
    rescue => e
      puts "Error fetching analytics data: #{e.message}"
      # Set sample data on error
      @monthly_stats = { monthly_stats: [] }
      @top_products = { top_products: [] }
      @sales_trends = { daily_trends: [] }
      @customer_patterns = { spending_patterns: [] }
    end
    
    haml :advanced_analytics
  end

  # MCP query endpoint
  post '/mcp/query' do
    content_type :json
    mcp = EcommerceMCP.new(settings.database)
    result = mcp.handle_query(params[:query])
    json result
  end

  # Natural Language Analytics endpoint
  post '/api/analyze' do
    content_type :json
    
    begin
      query = params[:query].to_s.downcase
      mcp = EcommerceMCP.new(settings.database)
      
      result = {}
      
      # Handle different types of queries
      if query.include?('top') && query.include?('product')
        result[:top_products] = mcp.handle_query("top selling products")
      end
      
      if query.include?('retention') || query.include?('customer')
        result[:spending_patterns] = mcp.handle_query("customer spending patterns")
      end
      
      if query.include?('price') || query.include?('sensitivity')
        result[:price_sensitivity] = mcp.handle_query("price sensitivity analysis")
      end
      
      if query.include?('revenue') || query.include?('sales')
        result[:monthly_stats] = mcp.handle_query("monthly orders")
      end
      
      if result.empty?
        # Default to showing top products if query type is unclear
        result[:top_products] = mcp.handle_query("top selling products")
      end
      
      json result
    rescue => e
      status 500
      json error: "Analysis failed: #{e.message}"
    end
  end
end
end

# Regional analytics
get '/analytics/region/:region' do
  @mcp = EcommerceMCP.new(settings.database)
  @region_data = @mcp.handle_query("product performance in #{params[:region]}")
  haml :region_analytics
end

# Category analytics
get '/analytics/category/:category' do
  @mcp = EcommerceMCP.new(settings.database)
  @category_data = @mcp.handle_query("category performance #{params[:category]}")
  haml :category_analytics
end

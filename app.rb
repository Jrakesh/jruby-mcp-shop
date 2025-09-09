require 'sinatra'
require 'sequel'
require 'haml'
require 'json'
require 'securerandom'
require_relative 'lib/ecommerce_mcp'

configure do
  enable :sessions
  set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }
  set :haml, format: :html5
  set :public_folder, File.expand_path('../public', __FILE__)
  set :views, File.expand_path('../views', __FILE__)
  set :bind, '0.0.0.0'
  set :port, 3000
  enable :logging, :dump_errors, :raise_errors

  # Database configuration
  DB = Sequel.connect(
    adapter: 'jdbc',
    uri: ENV['DATABASE_URL'] || 'jdbc:postgresql://localhost/ecommerce_db',
    user: ENV['DB_USER'] || 'postgres',
    password: ENV['DB_PASSWORD'] || 'postgres'
  )
  set :database, DB
end

# Load models after database configuration
Dir["#{File.dirname(__FILE__)}/models/*.rb"].each { |file| require file }

# Asset helpers
helpers do
  def asset_path(file_path)
    "/#{file_path}"
  end
  
  def javascript_include_tag(source)
    "<script src='#{asset_path(source)}' type='text/javascript'></script>"
  end
  
  def stylesheet_link_tag(source)
    "<link href='#{asset_path(source)}' rel='stylesheet' type='text/css'>"
  end
end

# API Routes
get '/api/analytics/realtime' do
  content_type :json
  
  begin
    db = settings.database
    today = Date.today

    # Calculate month range
    this_month_start = Date.new(today.year, today.month, 1)
    this_month_end = Date.new(today.year, today.month, -1)

    # Calculate today's range
    today_start = Time.new(today.year, today.month, today.day, 0, 0, 0)
    today_end = Time.new(today.year, today.month, today.day, 23, 59, 59)

    # Calculate today's revenue
    today_revenue = db[:orders]
      .where(Sequel[:orders][:created_at] => today_start..today_end)
      .join(:order_items, order_id: :id)
      .sum(Sequel[:order_items][:quantity] * Sequel[:order_items][:unit_price]) || 0

    # Calculate monthly revenue
    monthly_revenue = db[:orders]
      .where(Sequel[:orders][:created_at] => this_month_start..this_month_end)
      .join(:order_items, order_id: :id)
      .sum(Sequel[:order_items][:quantity] * Sequel[:order_items][:unit_price]) || 0

    # Calculate monthly orders
    monthly_orders = db[:orders]
      .where(Sequel[:orders][:created_at] => this_month_start..this_month_end)
      .count

    # Calculate conversion rate
    total_visitors = db[:analytics]
      .where(Sequel[:analytics][:created_at] => today_start..today_end)
      .count || 0
    completed_orders = db[:orders]
      .where(Sequel[:orders][:created_at] => today_start..today_end)
      .count
    conversion_rate = total_visitors > 0 ? (completed_orders.to_f / total_visitors * 100).round(2) : 0

    # Get top products for today using order dates
    top_products = db[:order_items]
      .join(:orders, { Sequel[:orders][:id] => Sequel[:order_items][:order_id] })
      .join(:products, { Sequel[:products][:id] => Sequel[:order_items][:product_id] })
      .where(Sequel[:orders][:created_at] => today_start..today_end)
      .group(Sequel[:products][:id], Sequel[:products][:name])
      .select(
        Sequel[:products][:name].as(:name),
        Sequel.function(:sum, Sequel[:order_items][:quantity]).as(:units_sold),
        Sequel.function(:sum, Sequel[:order_items][:quantity] * Sequel[:order_items][:unit_price]).as(:revenue)
      )
      .order(Sequel.desc(:units_sold))
      .limit(5)
      .all
      .map { |p| {
        name: p[:name],
        units_sold: p[:units_sold].to_i,
        revenue: p[:revenue].to_f
      }}

    # Return JSON response
    {
      today_revenue: today_revenue.to_f,
      monthly_revenue: monthly_revenue.to_f,
      monthly_orders: monthly_orders.to_i,
      conversion_rate: conversion_rate,
      top_products: top_products
    }.to_json
  rescue => e
    puts "[ERROR] Realtime analytics error: #{e.message}"
    puts e.backtrace.join("\n")
    status 500
    { error: "Failed to fetch realtime data: #{e.message}" }.to_json
  end
end

# Home page
get '/' do
  @products = Product.order(:name).all
  haml :index
end

# Basic Analytics Routes
get '/analytics' do
  content_type :html
  @mcp = EcommerceMCP.new(settings.database)
  
  begin
    # Gather all analytics data
    @monthly_stats = @mcp.handle_query("monthly orders")
    @top_products = @mcp.handle_query("top selling products")
    @sales_trends = @mcp.handle_query("sales trends")
    @inventory = @mcp.handle_query("inventory alerts")
    @customer_patterns = @mcp.handle_query("customer spending patterns")
    
    # Debug: Log data before rendering
    puts "
[DEBUG] Analytics Data:"
    puts "Monthly Stats: #{@monthly_stats.to_json}"
    puts "Top Products: #{@top_products.to_json}"
    puts "Sales Trends: #{@sales_trends.to_json}"
    puts "Inventory: #{@inventory.to_json}"
    puts "Customer Patterns: #{@customer_patterns.to_json}
"
  rescue => e
    puts "[ERROR] Failed to fetch analytics data: #{e.message}"
    puts e.backtrace
    
    # Set default empty data structures
    @monthly_stats = { monthly_stats: [] }
    @top_products = { top_products: [] }
    @sales_trends = { daily_trends: [] }
    @inventory = { alerts: [] }
    @customer_patterns = { spending_patterns: [] }
  end

  # Add some debug output
  puts "Monthly Stats: #{@monthly_stats.inspect}"
  puts "Top Products: #{@top_products.inspect}"
  puts "Sales Trends: #{@sales_trends.inspect}"
  puts "Inventory: #{@inventory.inspect}"
  puts "Customer Patterns: #{@customer_patterns.inspect}"
  
  haml :analytics
end

# MCP query endpoint
post '/mcp/query' do
  content_type :json
  mcp = EcommerceMCP.new(settings.database)
  result = mcp.handle_query(params[:query])
  json result
end

# Analytics routes
get '/analytics/advanced' do
  @title = "Advanced Analytics"
  haml :advanced_analytics
end

# Natural language analytics API endpoint
post '/api/analyze' do
  content_type :json
  
  begin
    mcp = EcommerceMCP.new(settings.database)
    
    # Parse JSON from request body - more compatible approach
    request_payload = {}
    if request.content_type && request.content_type.include?('application/json')
      begin
        body = request.body.read
        request_payload = JSON.parse(body) unless body.empty?
      rescue JSON::ParserError => e
        puts "[WARN] Failed to parse JSON: #{e.message}"
        request_payload = {}
      end
    end
    
    query = params[:query] || request_payload['query']
    
    unless query
      return { error: "No query provided" }.to_json
    end
    
    # Determine query type and return appropriate data
    result = case query.downcase
    when /top selling products/i, /best selling/i, /popular products/i
      products_data = mcp.handle_query("top selling products")
      { top_products: products_data[:top_products] || [] }
    when /customer retention/i, /retention/i
      retention_data = mcp.handle_query("customer retention")
      { retention_data: retention_data[:retention_analysis] || [] }
    when /price sensitivity/i, /pricing/i
      # Generate sample price sensitivity data since we may not have real pricing analysis
      price_data = generate_price_sensitivity_data(mcp)
      { price_sensitivity: price_data }
    when /monthly/i, /revenue/i, /sales trends/i
      monthly_data = mcp.handle_query("monthly orders")
      { monthly_stats: monthly_data[:monthly_stats] || [] }
    else
      # Default to top products
      products_data = mcp.handle_query("top selling products")
      { top_products: products_data[:top_products] || [] }
    end
    
    result.to_json
  rescue => e
    puts "[ERROR] Analytics API error: #{e.message}"
    puts e.backtrace.join("\n")
    { error: "Failed to fetch analytics data: #{e.message}" }.to_json
  end
end

def generate_price_sensitivity_data(mcp)
  # Generate realistic price sensitivity data from existing products
  begin
    db = mcp.instance_variable_get(:@db)
    products = db[:products]
      .join(:order_items, product_id: Sequel[:products][:id])
      .select(
        Sequel[:products][:name],
        Sequel[:products][:price],
        Sequel.function(:sum, Sequel[:order_items][:quantity]).as(:total_sold)
      )
      .group(Sequel[:products][:id], Sequel[:products][:name], Sequel[:products][:price])
      .order(Sequel.desc(:total_sold))
      .limit(10)
      .all
    
    # Transform to price sensitivity format
    products.map do |product|
      {
        name: product[:name],
        price: product[:price].to_f,
        volume: product[:total_sold].to_i,
        price_category: case product[:price].to_f
                       when 0..50 then 'Low'
                       when 51..100 then 'Medium'
                       else 'High'
                       end
      }
    end
  rescue => e
    puts "[ERROR] Price sensitivity generation error: #{e.message}"
    # Return sample data as fallback
    [
      { name: 'Product A', price: 25.99, volume: 150, price_category: 'Low' },
      { name: 'Product B', price: 45.99, volume: 120, price_category: 'Low' },
      { name: 'Product C', price: 75.99, volume: 85, price_category: 'Medium' },
      { name: 'Product D', price: 99.99, volume: 60, price_category: 'Medium' },
      { name: 'Product E', price: 149.99, volume: 35, price_category: 'High' },
      { name: 'Product F', price: 199.99, volume: 20, price_category: 'High' }
    ]
  end
end

# Export Routes
get '/analytics/export/:format' do
  @mcp = EcommerceMCP.new(settings.database)
  data = {
    monthly_stats: @mcp.handle_query("monthly orders"),
    top_products: @mcp.handle_query("top selling products"),
    customer_patterns: @mcp.handle_query("customer spending patterns")
  }

  case params[:format]
  when 'csv'
    content_type 'text/csv'
    attachment 'analytics_export.csv'
    AnalyticsController.generate_csv(data, params[:type] || 'sales')
  when 'excel'
    content_type 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    attachment 'analytics_export.xlsx'
    AnalyticsController.generate_excel(data)
  when 'json'
    content_type :json
    AnalyticsController.generate_json(data)
  else
    halt 400, "Unsupported format"
  end
end

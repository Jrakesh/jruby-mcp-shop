require 'csv'
require 'sinatra/base'
require 'json'
require 'date'

class AnalyticsController < Sinatra::Base
  def self.generate_csv(data, type)
    CSV.generate do |csv|
      case type
      when 'sales'
        csv << ['Date', 'Revenue', 'Orders', 'Average Order Value']
        data[:monthly_stats].each do |stat|
          csv << [stat[:month], stat[:revenue], stat[:order_count], (stat[:revenue] / stat[:order_count]).round(2)]
        end
      when 'products'
        csv << ['Product', 'Units Sold', 'Revenue', 'Average Price']
        data[:top_products].each do |product|
          csv << [product[:name], product[:units_sold], product[:revenue], (product[:revenue] / product[:units_sold]).round(2)]
        end
      when 'customers'
        csv << ['Email', 'Total Orders', 'Total Spent', 'Average Order', 'Last Order Date']
        data[:spending_patterns].each do |pattern|
          csv << [pattern[:email], pattern[:order_count], pattern[:total_spent], pattern[:average_order]]
        end
      end
    end
  end

  def self.generate_json(data)
    data.to_json
  end

  def self.generate_excel(data)
    require 'axlsx'
    
    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(name: "Analytics") do |sheet|
        sheet.add_row ["E-commerce Analytics Report"]
        sheet.add_row ["Generated at: #{Time.now}"]
        sheet.add_row []
        
        # Monthly Stats
        sheet.add_row ["Monthly Statistics"]
        sheet.add_row ["Month", "Revenue", "Orders", "Average Order Value"]
        data[:monthly_stats].each do |stat|
          sheet.add_row [
            stat[:month],
            stat[:revenue],
            stat[:order_count],
            (stat[:revenue] / stat[:order_count]).round(2)
          ]
        end

        sheet.add_row []

        # Top Products
        sheet.add_row ["Top Products"]
        sheet.add_row ["Product", "Units Sold", "Revenue", "Average Price"]
        data[:top_products].each do |product|
          sheet.add_row [
            product[:name],
            product[:units_sold],
            product[:revenue],
            (product[:revenue] / product[:units_sold]).round(2)
          ]
        end
      end
    end.to_stream.read
  end

  # Dashboard route
  get '/dashboard' do
    haml :realtime
  end

  # Realtime analytics API endpoint
  get '/realtime' do
    content_type :json
    
    begin
      today = Date.today
      this_month = today.beginning_of_month..today.end_of_month
      
      # Calculate revenue metrics
      today_revenue = Order.where(created_at: today.beginning_of_day..today.end_of_day)
                          .sum(:total_amount)
      monthly_revenue = Order.where(created_at: this_month)
                           .sum(:total_amount)
      
      # Calculate order metrics
      monthly_orders = Order.where(created_at: this_month).count
      
      # Calculate conversion rate
      total_visitors = Analytics.where(created_at: today.beginning_of_day..today.end_of_day).count
      completed_orders = Order.where(created_at: today.beginning_of_day..today.end_of_day).count
      conversion_rate = total_visitors > 0 ? (completed_orders.to_f / total_visitors * 100).round(2) : 0
      
      # Get top selling products
      top_products = Order.join(:order_items, order_id: :id)
                         .join(:products, id: :product_id)
                         .where(created_at: this_month)
                         .group(:product_id)
                         .select(
                           Sequel.as(:products__name, :name),
                           Sequel.function(:sum, :order_items__quantity).as(:units_sold),
                           Sequel.function(:sum, :order_items__total_price).as(:revenue)
                         )
                         .order(Sequel.desc(:revenue))
                         .limit(5)
                         .map { |p| {
                           name: p.name,
                           units_sold: p.units_sold.to_i,
                           revenue: p.revenue.to_f
                         }}
      
      {
        today_revenue: today_revenue,
        monthly_revenue: monthly_revenue,
        monthly_orders: monthly_orders,
        conversion_rate: conversion_rate,
        top_products: top_products
      }.to_json
    rescue => e
      logger.error("Realtime analytics error: #{e.message}")
      logger.error(e.backtrace.join("\n"))
      status 500
      { error: "An error occurred while fetching realtime data" }.to_json
    end
  end

  # Natural language analytics query endpoint
  post '/api/nl-analytics/query' do
    content_type :json
    logger = Logger.new(STDOUT)
    
    begin
      payload = JSON.parse(request.body.read)
      query = payload["query"].to_s.downcase
      logger.info("[DEBUG] Received query: #{query}")
      return { error: "No query provided" }.to_json if query.empty?

      # Log current state
      logger.info("[DEBUG] Current table counts:")
      order_count = DB["SELECT COUNT(*) as count FROM orders"].first[:count]
      product_count = DB["SELECT COUNT(*) as count FROM products"].first[:count]
      order_items_count = DB["SELECT COUNT(*) as count FROM order_items"].first[:count]
      logger.info("  Orders: #{order_count}")
      logger.info("  Products: #{product_count}")
      logger.info("  Order Items: #{order_items_count}")

      # Get data for the appropriate time period
      end_date = Date.today
      start_date = case query
        when /daily|today|24 hour/
          end_date - 1
        when /weekly|last week|7 day/
          end_date - 7
        when /monthly|30 day|last month/
          end_date - 30
        else
          end_date - 365  # Default to yearly
      end

      data = {}

      begin
        # Basic summary data
        summary = DB["SELECT 
          SUM(total_amount) as total_revenue,
          COUNT(*) as total_orders
          FROM orders 
          WHERE created_at BETWEEN ? AND ?", start_date, end_date].first

        top_product = DB["SELECT 
          p.name,
          SUM(oi.quantity) as units_sold
          FROM products p
          JOIN order_items oi ON p.id = oi.product_id
          JOIN orders o ON o.id = oi.order_id
          WHERE o.created_at BETWEEN ? AND ?
          GROUP BY p.id, p.name
          ORDER BY units_sold DESC
          LIMIT 1", start_date, end_date].first

        data[:summary] = {
          period: "Last #{(end_date - start_date).to_i} days",
          total_revenue: summary[:total_revenue].to_f,
          total_orders: summary[:total_orders],
          total_products: product_count,
          top_product: top_product
        }

        # Add revenue data if requested
        if query =~ /revenue|sales|money|earning|income/
          data[:revenue] = DB["SELECT 
            DATE_FORMAT(created_at, '%Y-%m-%d') as day,
            SUM(total_amount) as revenue,
            COUNT(*) as order_count
            FROM orders 
            WHERE created_at BETWEEN ? AND ?
            GROUP BY DATE_FORMAT(created_at, '%Y-%m-%d')
            ORDER BY day", start_date, end_date]
            .map { |r| {
              day: r[:day],
              revenue: r[:revenue].to_f,
              order_count: r[:order_count]
            }}
        end

        # Add product performance if requested
        if query =~ /product|item|selling/
          data[:products] = DB["SELECT 
            p.name,
            SUM(oi.quantity) as units_sold,
            SUM(oi.total_price) as revenue
            FROM products p
            JOIN order_items oi ON p.id = oi.product_id
            JOIN orders o ON o.id = oi.order_id
            WHERE o.created_at BETWEEN ? AND ?
            GROUP BY p.id, p.name
            ORDER BY revenue DESC
            LIMIT 10", start_date, end_date]
            .map { |p| {
              name: p[:name],
              units_sold: p[:units_sold].to_i,
              revenue: p[:revenue].to_f
            }}
        end

        # Add category performance if requested
        if query =~ /categor|group|type/
          data[:categories] = DB["SELECT 
            c.name,
            SUM(oi.total_price) as revenue
            FROM categories c
            JOIN products p ON c.id = p.category_id
            JOIN order_items oi ON p.id = oi.product_id
            JOIN orders o ON o.id = oi.order_id
            WHERE o.created_at BETWEEN ? AND ?
            GROUP BY c.id, c.name
            ORDER BY revenue DESC", start_date, end_date]
            .map { |c| {
              name: c[:name],
              revenue: c[:revenue].to_f
            }}
        end

        # Add customer spending patterns if requested
        if query =~ /customer|buyer|shopper|spend/
          data[:patterns] = DB["SELECT 
            email,
            SUM(total_amount) as total_spent,
            COUNT(*) as order_count
            FROM orders
            WHERE created_at BETWEEN ? AND ?
            GROUP BY email
            ORDER BY total_spent DESC
            LIMIT 10", start_date, end_date]
            .map { |p| {
              email: p[:email],
              total_spent: p[:total_spent].to_f,
              order_count: p[:order_count]
            }}
        end

        logger.info("[DEBUG] Query result: #{data.inspect}")
        { data: data }.to_json
      rescue => e
        logger.error("Database error: #{e.message}")
        logger.error(e.backtrace.join("\n"))
        status 500
        { error: "Database error: #{e.message}" }.to_json
      end
    rescue => e
      logger.error("Request processing error: #{e.message}")
      logger.error(e.backtrace.join("\n"))
      status 500
      { error: "An error occurred while processing the request: #{e.message}" }.to_json
    end
  end
end

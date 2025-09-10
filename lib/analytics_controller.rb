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
end

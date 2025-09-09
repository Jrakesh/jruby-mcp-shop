require 'fast_mcp'
require 'date'
require 'json'
require_relative 'debug_logger'

class EcommerceMCP
  def initialize(db)
    @db = db
    @debug = true  # Set to true to enable query debugging
    
    # Verify data exists in tables
    puts "[DEBUG] Table row counts:"
    puts "Orders: #{@db[:orders].count}"
    puts "Products: #{@db[:products].count}"
    puts "Customers: #{@db[:customers].count}"
    puts "Order Items: #{@db[:order_items].count}"
  end

  def debug_query(method_name)
    puts "[DEBUG] Starting #{method_name}..." if @debug
    result = yield
    if @debug
      puts "[DEBUG] #{method_name} SQL:"
      puts result.sql if result.respond_to?(:sql)
      puts "[DEBUG] #{method_name} result:"
      puts result.inspect
    end
    result
  end

  def handle_query(query)
    puts "\n[DEBUG] Starting query handling..."
    puts "[DEBUG] Received query: #{query}"
    puts "[DEBUG] Current table counts:"
    puts "  Orders: #{@db[:orders].count}"
    puts "  Products: #{@db[:products].count}"
    puts "  Order Items: #{@db[:order_items].count}"
    
    result = case query.downcase
    when /monthly orders/i, /orders per month/i
      monthly_orders_stats
    when /top selling products/i
      top_selling_products
    when /orders from (.+)/i
      orders_by_location($1)
    when /peak (months|periods)/i
      peak_sales_periods
    when /average order value/i
      average_order_value
    when /customer spending patterns/i
      customer_spending_patterns
    when /product performance in (.+)/i
      product_performance_by_region($1)
    when /inventory alerts/i
      low_stock_alerts
    when /sales trends/i
      sales_trends_analysis
    when /popular product combinations/i
      popular_product_combinations
    when /category performance (.+)/i
      category_performance($1)
    when /customer retention/i
      customer_retention_analysis
    when /price sensitivity/i
      price_sensitivity_analysis
    when /seasonal trends/i
      seasonal_trends_analysis
    when /customer lifetime value/i
      customer_lifetime_value
    when /product affinity/i
      product_affinity_analysis
    else
      { error: "Query not understood" }
    end
    puts "[DEBUG] Query result: #{result.inspect}"
    result
  end

  private

  def monthly_orders_stats
    puts "[DEBUG] Running monthly_orders_stats query..."
    orders = @db[:orders]
      .join(:order_items, order_id: Sequel[:orders][:id])
      .select(
        Sequel.function(:date_trunc, 'month', Sequel[:orders][:created_at]).as(:month),
        Sequel.function(:count, Sequel.qualify(:orders, :id)).distinct.as(:order_count),
        Sequel.function(:sum, Sequel[:order_items][:quantity] * Sequel[:order_items][:unit_price]).as(:total_revenue)
      )
      .group(Sequel.function(:date_trunc, 'month', Sequel[:orders][:created_at]))
      .order(Sequel.desc(:month))
      .all

    result = {
      monthly_stats: orders.map { |o| 
        {
          month: o[:month].strftime('%Y-%m'),
          order_count: o[:order_count],
          revenue: o[:total_revenue].to_f
        }
      }
    }
  end

  def top_selling_products(limit = 10)
    products = @db[:order_items]
      .join(:products, id: Sequel[:order_items][:product_id])
      .group(Sequel[:products][:id], Sequel[:products][:name])
      .select(
        Sequel[:products][:name].as(:name),
        Sequel.function(:sum, Sequel[:order_items][:quantity]).as(:total_sold),
        Sequel.function(:sum, Sequel[:order_items][:quantity] * Sequel[:order_items][:unit_price]).as(:total_revenue)
      )
      .order(Sequel.desc(:total_sold))
      .limit(limit)
      .all

    {
      top_products: products.map { |p|
        {
          name: p[:name],
          units_sold: p[:total_sold],
          revenue: p[:total_revenue].to_f
        }
      }
    }
  end

  def product_performance_by_region(region)
    products = @db[:order_items]
      .join(:orders, id: :order_id)
      .join(:products, id: :product_id)
      .where(Sequel.like(Sequel[:orders][:shipping_address], "%#{region}%"))
      .group(Sequel[:products][:id], Sequel[:products][:name])
      .select(
        Sequel[:products][:name],
        Sequel.function(:sum, Sequel[:order_items][:quantity]).as(:total_sold),
        Sequel.function(:avg, Sequel[:order_items][:unit_price]).as(:avg_price)
      )
      .order(Sequel.desc(:total_sold))
      .all

    {
      region: region,
      products: products.map { |p|
        {
          name: p[:name],
          units_sold: p[:total_sold],
          average_price: p[:avg_price].to_f
        }
      }
    }
  end

  def customer_spending_patterns
    patterns = @db[:orders]
      .join(:customers, id: Sequel[:orders][:customer_id])
      .join(:order_items, order_id: Sequel[:orders][:id])
      .group(Sequel[:customers][:id], Sequel[:customers][:email])
      .select(
        Sequel[:customers][:email].as(:email),
        Sequel.function(:count, Sequel.qualify(:orders, :id)).as(:order_count),
        Sequel.function(:avg, Sequel[:order_items][:quantity] * Sequel[:order_items][:unit_price]).as(:avg_order_value),
        Sequel.function(:sum, Sequel[:order_items][:quantity] * Sequel[:order_items][:unit_price]).as(:total_spent)
      )
      .order(Sequel.desc(:total_spent))
      .limit(10)
      .all

    {
      spending_patterns: patterns.map { |p|
        {
          email: p[:email],
          order_count: p[:order_count],
          average_order: p[:avg_order_value].to_f,
          total_spent: p[:total_spent].to_f
        }
      }
    }
  end

  def popular_product_combinations
    combinations = @db[:order_items]
      .join(:products, id: :product_id)
      .where(order_id: @db[:order_items].select(:order_id).group(:order_id).having { count('*') > 1 })
      .group(:order_id)
      .having { count('*') > 1 }
      .select(
        Sequel.function(:array_agg, :name).as(:product_names),
        Sequel.function(:count, '*').as(:frequency)
      )
      .order(Sequel.desc(:frequency))
      .limit(5)
      .all

    {
      popular_combinations: combinations.map { |c|
        {
          products: c[:product_names],
          frequency: c[:frequency]
        }
      }
    }
  end

  def low_stock_alerts(threshold = 20)
    low_stock = @db[:products]
      .where { stock <= threshold }
      .select(
        Sequel[:products][:name].as(:name),
        Sequel[:products][:stock].as(:stock)
      )
      .order(Sequel[:products][:stock])
      .all

    {
      alerts: low_stock.map { |p|
        {
          product: p[:name],
          stock_level: p[:stock],
          status: p[:stock] == 0 ? 'Out of Stock' : 'Low Stock'
        }
      }
    }
  end

  def sales_trends_analysis
    daily_sales = @db[:order_items]
      .join(:orders, id: Sequel[:order_items][:order_id])
      .select(
        Sequel.function(:date_trunc, 'day', Sequel[:orders][:created_at]).as(:date),
        Sequel.function(:sum, Sequel[:order_items][:quantity] * Sequel[:order_items][:unit_price]).as(:daily_revenue),
        Sequel.function(:count, Sequel.qualify(:orders, :id)).distinct.as(:order_count)
      )
      .group(Sequel.function(:date_trunc, 'day', Sequel[:orders][:created_at]))
      .order(Sequel.desc(:date))
      .limit(30)
      .all

    {
      daily_trends: daily_sales.map { |s|
        {
          date: s[:date].strftime('%Y-%m-%d'),
          revenue: s[:daily_revenue].to_f
        }
      }
    }
  end

  def category_performance(category)
    products = @db[:order_items]
      .join(:products, id: :product_id)
      .where(Sequel[:products][:category] => category)
      .group(Sequel[:products][:id], Sequel[:products][:name])
      .select(
        Sequel[:products][:name],
        Sequel.function(:sum, Sequel[:order_items][:quantity]).as(:total_sold),
        Sequel.function(:sum, Sequel[:order_items][:quantity] * Sequel[:order_items][:unit_price]).as(:total_revenue),
        Sequel.function(:avg, Sequel[:order_items][:unit_price]).as(:avg_price)
      )
      .order(Sequel.desc(:total_revenue))
      .all

    {
      category: category,
      total_revenue: products.sum { |p| p[:total_revenue].to_f },
      products: products.map { |p|
        {
          name: p[:name],
          units_sold: p[:total_sold],
          revenue: p[:total_revenue].to_f,
          average_price: p[:avg_price].to_f
        }
      }
    }
  end

  def customer_retention_analysis
    retention = @db[:orders]
      .join(:customers, id: Sequel[:orders][:customer_id])
      .group(Sequel[:customers][:id], Sequel[:customers][:email])
      .select(
        Sequel[:customers][:email].as(:email),
        Sequel.function(:count, Sequel.qualify(:orders, :id)).as(:order_count),
        Sequel.function(:min, Sequel[:orders][:created_at]).as(:first_order),
        Sequel.function(:max, Sequel[:orders][:created_at]).as(:last_order)
      )
      .having { count(Sequel.qualify(:orders, :id)) > 1 }
      .order(Sequel.desc(:order_count))
      .all

    {
      retention_data: retention.map { |r|
        {
          email: r[:email],
          order_count: r[:order_count],
          days_between_orders: (r[:last_order] - r[:first_order]).to_i / 86400,
          customer_age_days: (Time.now - r[:first_order]).to_i / 86400
        }
      }
    }
  end

  def price_sensitivity_analysis
    sensitivity = @db[:order_items]
      .join(:products, id: :product_id)
      .group(Sequel[:products][:id], Sequel[:products][:name])
      .select(
        Sequel[:products][:name],
        Sequel.function(:avg, Sequel[:order_items][:unit_price]).as(:avg_price),
        Sequel.function(:sum, Sequel[:order_items][:quantity]).as(:total_sold),
        Sequel.function(:corr, Sequel[:order_items][:unit_price], Sequel[:order_items][:quantity]).as(:price_sensitivity)
      )
      .having { count('*') > 5 }
      .order(Sequel.desc(:price_sensitivity))
      .all

    {
      price_sensitivity: sensitivity.map { |s|
        {
          product: s[:name],
          average_price: s[:avg_price].to_f,
          total_sold: s[:total_sold],
          sensitivity_score: s[:price_sensitivity].to_f
        }
      }
    }
  end

  def seasonal_sales_trends
    trends = @db[:orders]
      .join(:customers, id: Sequel[:orders][:customer_id])
      .join(:order_items, order_id: Sequel[:orders][:id])
      .select(
        Sequel.extract(:month, :created_at).as(:month),
        Sequel.extract(:year, :created_at).as(:year),
        Sequel.function(:sum, Sequel[:order_items][:quantity] * Sequel[:order_items][:unit_price]).as(:total_sales),
        Sequel.function(:count, Sequel.qualify(:orders, :id)).distinct.as(:order_count),
        Sequel.function(:count, Sequel[:customers][:email]).distinct.as(:unique_customers)
      )
      .group(Sequel.extract(:year, :created_at), Sequel.extract(:month, :created_at))
      .order(Sequel.extract(:year, :created_at), Sequel.extract(:month, :created_at))
      .limit(12)
      .all

    {
      seasonal_trends: trends.map { |t|
        {
          year: t[:year],
          month: t[:month],
          total_sales: t[:total_sales].to_f,
          order_count: t[:order_count],
          unique_customers: t[:unique_customers]
        }
      }
    }
  end

  def customer_lifetime_value
    clv = @db[:orders]
      .join(:customers, id: Sequel[:orders][:customer_id])
      .join(:order_items, order_id: Sequel[:orders][:id])
      .group(Sequel[:customers][:email])
      .select(
        Sequel[:customers][:email].as(:email),
        Sequel.function(:sum, Sequel[:order_items][:quantity] * Sequel[:order_items][:unit_price]).as(:total_value),
        Sequel.function(:count, Sequel.qualify(:orders, :id)).as(:order_count),
        Sequel.function(:min, Sequel[:orders][:created_at]).as(:first_order)
      )
      .order(Sequel.desc(:total_value))
      .limit(10)
      .all

    {
      customer_lifetime_values: clv.map { |c|
        months_active = ((Time.now - c[:first_order]) / (30 * 24 * 60 * 60)).ceil
        {
          email: c[:email],
          total_value: c[:total_value].to_f,
          order_count: c[:order_count],
          months_active: months_active,
          monthly_value: (c[:total_value].to_f / months_active).round(2)
        }
      }
    }
  end

  def product_affinity_analysis
    affinity = @db[:order_items]
      .join(:products, id: :product_id)
      .where(order_id: @db[:order_items]
        .select(:order_id)
        .group(:order_id)
        .having { count('*') > 1 }
      )
      .group([:order_id, Sequel[:products][:category]])
      .select(
        Sequel[:products][:category],
        Sequel.function(:count, :order_id).as(:frequency)
      )
      .order(Sequel.desc(:frequency))
      .all

    category_pairs = affinity.combination(2).map do |a, b|
      {
        categories: [a[:category], b[:category]],
        frequency: [a[:frequency], b[:frequency]].min
      }
    end

    {
      category_affinities: category_pairs.sort_by { |pair| -pair[:frequency] }
    }
  end


end

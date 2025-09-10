# Advanced Analytics Routes
class EcommerceApp < Sinatra::Base
  get '/analytics/advanced' do
    @mcp = EcommerceMCP.new(settings.database)
    
    @monthly_stats = @mcp.handle_query("monthly orders")
    @top_products = @mcp.handle_query("top selling products")
    @sales_trends = @mcp.handle_query("sales trends")
    @customer_patterns = @mcp.handle_query("customer spending patterns")
    @category_performance = @mcp.handle_query("category performance all")
    @customer_retention = @mcp.handle_query("customer retention")
    
    haml :advanced_analytics
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



  # Specialized Reports
  get '/analytics/reports/:type' do
    @mcp = EcommerceMCP.new(settings.database)
    
    @report_data = case params[:type]
    when 'customer-cohort'
      @mcp.handle_query("customer retention")
    when 'product-affinity'
      @mcp.handle_query("product affinity")
    when 'price-sensitivity'
      @mcp.handle_query("price sensitivity")
    when 'seasonal'
      @mcp.handle_query("seasonal trends")
    else
      halt 400, "Unknown report type"
    end

    haml :"reports/#{params[:type]}"
  end
end

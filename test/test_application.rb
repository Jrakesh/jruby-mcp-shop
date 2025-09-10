require_relative 'test_helper'

class TestApplication < Minitest::Test
  def setup
    TestHelper.setup_test_data
  end

  def teardown
    TestHelper.cleanup_test_data
  end

  def test_home_page_loads
    get '/'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'JRuby MCP Shop'
  end

  def test_analytics_page_loads
    get '/analytics'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Analytics Dashboard'
  end

  def test_hotels_restaurants_page_loads
    get '/hotels-restaurants'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Hotels & Restaurants'
  end

  def test_flights_page_loads
    get '/flights'
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'Flight Search'
  end

  def test_products_api_endpoint
    get '/api/products'
    assert_equal 200, last_response.status
    
    response_data = JSON.parse(last_response.body)
    assert response_data.is_a?(Array)
  end

  def test_analytics_data_endpoint
    get '/api/analytics/data'
    assert_equal 200, last_response.status
    
    response_data = JSON.parse(last_response.body)
    assert response_data.key?('revenue_trends')
    assert response_data.key?('product_performance')
    assert response_data.key?('customer_segments')
  end

  def test_hotels_search_with_location
    post '/api/search/hotels-restaurants', { location: 'Mumbai' }
    assert_equal 200, last_response.status
    
    response_data = JSON.parse(last_response.body)
    assert response_data.key?('results')
    assert response_data['results'].is_a?(Array)
  end

  def test_flights_search_with_valid_params
    post '/api/search/flights', {
      origin: 'Mumbai',
      destination: 'Delhi',
      departure_date: '2025-12-01',
      passengers: '1'
    }
    assert_equal 200, last_response.status
    
    response_data = JSON.parse(last_response.body)
    assert response_data.key?('results')
    assert response_data['results'].is_a?(Array)
  end

  def test_invalid_endpoint_returns_404
    get '/nonexistent-page'
    assert_equal 404, last_response.status
  end
end

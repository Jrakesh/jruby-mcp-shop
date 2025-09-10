require_relative 'test_helper'
require_relative '../lib/serpapi_service'

class TestSerpApiService < Minitest::Test
  def setup
    @service = SerpApiService.new
  end

  def test_initialization
    assert_instance_of SerpApiService, @service
    assert_respond_to @service, :search_hotels_restaurants
    assert_respond_to @service, :search_flights
  end

  def test_get_coordinates_for_known_city
    coordinates = @service.send(:get_coordinates, 'mumbai')
    assert_equal '19.0760,72.8777', coordinates
  end

  def test_get_coordinates_for_unknown_city
    coordinates = @service.send(:get_coordinates, 'unknown_city')
    assert_equal '28.7041,77.1025', coordinates # Default to Delhi
  end

  def test_get_airport_code_for_known_city
    airport_code = @service.send(:get_airport_code, 'mumbai')
    assert_equal 'BOM', airport_code
  end

  def test_get_airport_code_for_unknown_city
    airport_code = @service.send(:get_airport_code, 'unknowncity')
    assert_equal 'UNK', airport_code # First 3 chars fallback
  end

  def test_search_hotels_restaurants_returns_demo_data
    result = @service.search_hotels_restaurants('Mumbai')
    
    assert result.key?('results')
    assert result['results'].is_a?(Array)
    assert result['results'].length > 0
    
    # Check demo data structure
    first_result = result['results'].first
    assert first_result.key?('title')
    assert first_result.key?('address')
    assert first_result.key?('rating')
    assert first_result.key?('price_range')
  end

  def test_search_flights_returns_demo_data
    result = @service.search_flights('Mumbai', 'Delhi', '2025-12-01')
    
    assert result.key?('results')
    assert result['results'].is_a?(Array)
    assert result['results'].length > 0
    
    # Check demo data structure
    first_result = result['results'].first
    assert first_result.key?('airline')
    assert first_result.key?('flight_number')
    assert first_result.key?('departure_airport')
    assert first_result.key?('arrival_airport')
    assert first_result.key?('price')
  end

  def test_format_hotels_restaurants_results_with_empty_data
    result = @service.send(:format_hotels_restaurants_results, {})
    
    assert result.key?('results')
    assert_equal 2, result['results'].length # Demo data
  end

  def test_format_flights_results_with_empty_data
    result = @service.send(:format_flights_results, {})
    
    assert result.key?('results')
    assert_equal 2, result['results'].length # Demo data
  end

  def test_demo_hotels_restaurants_data_structure
    demo_data = @service.send(:get_demo_hotels_restaurants_data, 'Test City')
    
    assert demo_data.is_a?(Array)
    assert_equal 3, demo_data.length
    
    demo_data.each do |item|
      assert item.key?(:title)
      assert item.key?(:address)
      assert item.key?(:rating)
      assert item.key?(:type)
      assert item.key?(:phone)
    end
  end

  def test_demo_flights_data_structure
    demo_data = @service.send(:get_demo_flights_data, 'Mumbai', 'Delhi', '2025-12-01', nil)
    
    assert demo_data.is_a?(Array)
    assert_equal 3, demo_data.length
    
    demo_data.each do |item|
      assert item.key?(:airline)
      assert item.key?(:flight_number)
      assert item.key?(:departure_airport)
      assert item.key?(:arrival_airport)
      assert item.key?(:duration)
      assert item.key?(:price)
    end
  end
end

require 'minitest/autorun'
require 'minitest/spec'
require 'rack/test'
require 'json'

# Set test environment
ENV['RACK_ENV'] = 'test'

# Load the application
require_relative '../app'

# Include Rack::Test for HTTP testing
class Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
end

# Test configuration
class TestHelper
  def self.setup_test_data
    # Create test products if needed
    unless Product.where(name: 'Test Product').first
      Product.create(
        name: 'Test Product',
        description: 'A test product for unit testing',
        price: 99.99,
        image_url: 'https://via.placeholder.com/300',
        category: 'Electronics'
      )
    end

    # Create test orders if needed
    unless Order.where(customer_name: 'Test Customer').first
      Order.create(
        customer_name: 'Test Customer',
        customer_email: 'test@example.com',
        total: 199.98,
        status: 'completed',
        created_at: Time.now - 86400 # 1 day ago
      )
    end
  end

  def self.cleanup_test_data
    # Clean up test data if needed
    Product.where(name: 'Test Product').delete
    Order.where(customer_name: 'Test Customer').delete
  end
end

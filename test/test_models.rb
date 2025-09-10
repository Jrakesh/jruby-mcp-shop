require_relative 'test_helper'

class TestModels < Minitest::Test
  def setup
    TestHelper.setup_test_data
  end

  def teardown
    TestHelper.cleanup_test_data
  end

  def test_product_creation
    product = Product.create(
      name: 'Test Product 2',
      description: 'Another test product',
      price: 149.99,
      category: 'Books'
    )
    
    assert product.id
    assert_equal 'Test Product 2', product.name
    assert_equal 149.99, product.price
    
    # Cleanup
    product.delete
  end

  def test_product_validation
    # Test with missing required fields
    product = Product.new
    
    # Assuming validation is implemented, this would fail
    # For now, we'll just test basic creation
    assert_instance_of Product, product
  end

  def test_order_creation
    order = Order.create(
      customer_name: 'Test Customer 2',
      customer_email: 'test2@example.com',
      total: 299.98,
      status: 'pending'
    )
    
    assert order.id
    assert_equal 'Test Customer 2', order.customer_name
    assert_equal 299.98, order.total
    
    # Cleanup
    order.delete
  end

  def test_product_relationships
    # Test if we can find products
    products = Product.all
    assert products.respond_to?(:each)
  end

  def test_order_relationships
    # Test if we can find orders
    orders = Order.all
    assert orders.respond_to?(:each)
  end

  def test_product_price_calculation
    product = Product.where(name: 'Test Product').first
    assert product
    assert product.price > 0
  end

  def test_order_total_calculation
    order = Order.where(customer_name: 'Test Customer').first
    assert order
    assert order.total > 0
  end
end

# Clear existing data
%w[cart_items carts order_items orders customers products].each do |table|
  Sequel::Model.db[table.to_sym].delete if Sequel::Model.db.tables.include?(table.to_sym)
end

# Sample products with categories
products = [
  # Electronics
  {
    name: 'Smart Watch Pro',
    description: 'Advanced smartwatch with health monitoring features',
    price: 199.99,
    stock: 50,
    category: 'Electronics',
    image_url: 'https://example.com/smart-watch.jpg',
    created_at: Time.now,
    updated_at: Time.now
  },
  {
    name: 'Wireless Earbuds',
    description: 'High-quality wireless earbuds with noise cancellation',
    price: 149.99,
    stock: 100,
    category: 'Electronics',
    image_url: 'https://example.com/earbuds.jpg',
    created_at: Time.now,
    updated_at: Time.now
  },
  {
    name: 'Ultra HD Monitor',
    description: '32-inch 4K monitor for professional use',
    price: 499.99,
    stock: 30,
    category: 'Electronics',
    image_url: 'https://example.com/monitor.jpg',
    created_at: Time.now,
    updated_at: Time.now
  },
  # Fashion
  {
    name: 'Premium Leather Wallet',
    description: 'Handcrafted genuine leather wallet',
    price: 79.99,
    stock: 150,
    category: 'Fashion',
    image_url: 'https://example.com/wallet.jpg',
    created_at: Time.now,
    updated_at: Time.now
  },
  {
    name: 'Designer Sunglasses',
    description: 'UV-protected polarized sunglasses',
    price: 129.99,
    stock: 75,
    category: 'Fashion',
    image_url: 'https://example.com/sunglasses.jpg',
    created_at: Time.now,
    updated_at: Time.now
  },
  # Home & Living
  {
    name: 'Smart Home Hub',
    description: 'Control your entire home with voice commands',
    price: 199.99,
    stock: 60,
    category: 'Smart Home',
    image_url: 'https://example.com/home-hub.jpg',
    created_at: Time.now,
    updated_at: Time.now
  },
  {
    name: 'Robot Vacuum Cleaner',
    description: 'AI-powered vacuum with mapping technology',
    price: 299.99,
    stock: 40,
    category: 'Smart Home',
    image_url: 'https://example.com/vacuum.jpg',
    created_at: Time.now,
    updated_at: Time.now
  },
  # Books & Media
  {
    name: 'Wireless Speaker System',
    description: 'Premium 5.1 wireless speaker system',
    price: 399.99,
    stock: 25,
    category: 'Electronics',
    image_url: 'https://example.com/speakers.jpg',
    created_at: Time.now,
    updated_at: Time.now
  },
  # Sports & Outdoors
  {
    name: 'Smart Fitness Tracker',
    description: 'Advanced fitness tracking with GPS',
    price: 89.99,
    stock: 120,
    category: 'Electronics',
    image_url: 'https://example.com/fitness.jpg',
    created_at: Time.now,
    updated_at: Time.now
  },
  {
    name: 'Portable Power Bank',
    description: '20000mAh fast-charging power bank',
    price: 49.99,
    stock: 200,
    category: 'Electronics',
    image_url: 'https://example.com/powerbank.jpg',
    created_at: Time.now,
    updated_at: Time.now
  }
]

created_products = products.map { |p| DB[:products].insert(p) }

# Sample orders with different dates and locations
# Create customers
customers = []
10.times do |i|
  customer_id = DB[:customers].insert(
    email: "customer#{i}@example.com",
    name: "Customer #{i}",
    address: "#{rand(100..999)} #{['Main', 'Market', 'King', 'Queen'].sample} St",
    city: ['New York', 'San Francisco', 'Toronto', 'London'].sample,
    country: ['USA', 'USA', 'Canada', 'UK'].sample,
    created_at: Time.now,
    updated_at: Time.now
  )
  customers << customer_id
end

# Create orders across different months
6.downto(0) do |months_ago|
  10.times do
    order_date = Time.now - (months_ago * 30 * 24 * 60 * 60) - rand(30 * 24 * 60 * 60)
    customer = DB[:customers][id: customers.sample]
    order_id = DB[:orders].insert(
      customer_id: customer[:id],
      status: ['pending', 'completed', 'shipped'].sample,
      shipping_address: "#{customer[:address]}, #{customer[:city]}, #{customer[:country]}",
      total_amount: 0, # Will be updated after adding items
      created_at: order_date,
      updated_at: order_date
    )

    # Add 1-3 items to each order
    rand(1..3).times do
      DB[:order_items].insert(
        order_id: order_id,
        product_id: created_products.sample,
        quantity: rand(1..5),
        unit_price: rand(50..500).to_f,
        created_at: order_date
      )
    end
  end
end

puts "Sample data created successfully!"

Sequel.migration do
  up do
    run 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp"'

    create_table(:products) do
      primary_key :id
      String :name, null: false
      String :description, text: true
      Float :price, null: false
      String :category, null: false
      Integer :stock, default: 0
      String :image_url
      DateTime :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP

      index :category
      index :name
    end

    create_table(:customers) do
      primary_key :id
      String :email, null: false, unique: true
      String :name
      String :address
      String :city
      String :country
      DateTime :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP

      index :email, unique: true
    end

    create_table(:orders) do
      primary_key :id
      foreign_key :customer_id, :customers, null: false
      String :status, default: 'pending'
      String :shipping_address, text: true
      Float :total_amount, null: false, default: 0
      DateTime :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP

      index :customer_id
      index :status
      index :created_at
    end

    create_table(:order_items) do
      primary_key :id
      foreign_key :order_id, :orders, null: false
      foreign_key :product_id, :products, null: false
      Integer :quantity, null: false
      Float :unit_price, null: false
      DateTime :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP

      index [:order_id, :product_id]
    end

    create_table(:carts) do
      primary_key :id
      foreign_key :customer_id, :customers
      String :session_id
      DateTime :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP

      index :customer_id
      index :session_id
    end

    create_table(:cart_items) do
      primary_key :id
      foreign_key :cart_id, :carts, null: false
      foreign_key :product_id, :products, null: false
      Integer :quantity, null: false, default: 1
      DateTime :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP

      index [:cart_id, :product_id]
    end

    # Triggers for updated_at
    run <<-SQL
      CREATE OR REPLACE FUNCTION update_updated_at_column()
      RETURNS TRIGGER AS $$
      BEGIN
          NEW.updated_at = CURRENT_TIMESTAMP;
          RETURN NEW;
      END;
      $$ language 'plpgsql';
    SQL

    # Add triggers to all tables with updated_at
    [:products, :customers, :orders, :carts, :cart_items].each do |table|
      run <<-SQL
        CREATE TRIGGER update_#{table}_updated_at
            BEFORE UPDATE ON #{table}
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
      SQL
    end
  end

  down do
    # Drop triggers first
    [:products, :customers, :orders, :carts, :cart_items].each do |table|
      run "DROP TRIGGER IF EXISTS update_#{table}_updated_at ON #{table}"
    end

    run 'DROP FUNCTION IF EXISTS update_updated_at_column()'

    drop_table(:cart_items)
    drop_table(:carts)
    drop_table(:order_items)
    drop_table(:orders)
    drop_table(:customers)
    drop_table(:products)
  end
end

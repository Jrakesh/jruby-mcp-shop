class Product < Sequel::Model
  one_to_many :order_items
  many_to_many :orders, through: :order_items
  
  def validate
    super
    errors.add(:name, 'cannot be empty') if !name || name.empty?
    errors.add(:price, 'must be greater than 0') if !price || price <= 0
  end
end

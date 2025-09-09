class Order < Sequel::Model
  one_to_many :order_items
  many_to_many :products, through: :order_items
  
  def validate
    super
    errors.add(:customer_email, 'cannot be empty') if !customer_email || customer_email.empty?
    errors.add(:status, 'cannot be empty') if !status || status.empty?
  end
  
  def total_amount
    order_items.sum { |item| item.quantity * item.unit_price }
  end
end

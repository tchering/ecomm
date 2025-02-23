class ProductOrder < ApplicationRecord
  belongs_to :product
  belongs_to :order

  validates :quantity, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :set_price, on: :create

  after_create :update_order_total

  private

  def set_price
    self.price = product.price if price.nil?
  end

  def update_order_total
    total = order.product_orders.sum { |line| line.quantity * line.product.price }
    order.update_column(:total, total) #update database column for orders/total
  end
end

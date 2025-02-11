class ProductOrder < ApplicationRecord
  belongs_to :product
  belongs_to :order

  validates :quantity, numericality: { greater_than: 0 }
  # validates :price, presence: true

  after_create :update_order_total

  private

  def update_order_total
    total = order.product_orders.sum { |line| line.quantity * line.product.price }
    order.update_column(:total, total) #update database column for orders/total
  end
end

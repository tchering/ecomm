class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 1 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_save :set_price

  def total_price
    quantity * price
  end

  private

  def set_price
    self.price = product.price if price.nil?
  end
end

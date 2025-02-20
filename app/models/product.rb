class Product < ApplicationRecord
  belongs_to :category
  has_many_attached :images
  has_many :stocks, dependent: :destroy
  has_many :product_orders
  has_many :orders, through: :product_orders

  validates :tax_rate, numericality: {
                         greater_than_or_equal_to: 0,
                         less_than_or_equal_to: 100,
                         allow_nil: true,
                       }

  # Returns the effective tax rate for this product
  # Uses product's tax_rate if set, otherwise falls back to category's tax_rate
  def effective_tax_rate
    tax_rate.presence || category.tax_rate
  end

  # Calculate tax amount for a given price
  def calculate_tax(price)
    price * (effective_tax_rate / 100.0)
  end

  # Calculate total price including tax
  def price_with_tax(price)
    price + calculate_tax(price)
  end
end

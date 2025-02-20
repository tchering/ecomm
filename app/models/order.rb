class Order < ApplicationRecord
  validates :name, :email, :address, :total, presence: true

  has_many :product_orders, dependent: :destroy
  has_many :products, through: :product_orders
  # STATUS = ["pending", "processing", "shipped", "delivered"]

  # validates :status, inclusion: { in: STATUS }

  enum status: {
    pending: 0,
    processing: 1,
    shipped: 2,
    delivered: 3,
    cancelled: 4,
  }

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true

  before_validation :set_default_status, on: :create

  before_validation :set_total_from_cart, on: :create

  TAX_RATE = 0.13

  def subtotal
    product_orders.sum { |po| po.quantity * po.price }
  end

  def tax_amount
    subtotal * TAX_RATE
  end

  def total_with_tax
    subtotal + tax_amount
  end

  private

  def set_total_from_cart
    return unless total.nil? && Current.cart.present?
    self.total = Current.cart.total * (1 + TAX_RATE) # Include tax in the total
  end

  def set_default_status
    self.status ||= :pending
  end
end

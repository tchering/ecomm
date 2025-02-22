class Order < ApplicationRecord
  belongs_to :cart, optional: true

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
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, format: { with: /\A\+?[\d\s-]+\z/, message: "format is invalid" }, allow_blank: true
  validates :shipping_address, :shipping_city, :shipping_state, :shipping_postal_code, presence: true
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true

  before_validation :set_default_status, on: :create

  before_validation :set_total_from_cart, on: :create

  def subtotal
    product_orders.sum { |po| po.quantity * po.price }
  end

  def tax_amount
    product_orders.sum do |po|
      po.product.calculate_tax(po.price * po.quantity)
    end
  end

  def total_with_tax
    subtotal + tax_amount
  end

  def calculate_total
    return unless cart.present?
    self.total = cart.total
  end

  private

  def set_total_from_cart
    return unless total.nil? && Current.cart.present?

    # Calculate total including tax for each item in cart
    self.total = Current.cart.cart_items.sum do |item|
      item.product.price_with_tax(item.price * item.quantity)
    end
  end

  def set_default_status
    self.status ||= :pending
  end
end

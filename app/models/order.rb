class Order < ApplicationRecord
  belongs_to :cart, optional: true
  belongs_to :user, optional: true

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
  before_validation :associate_with_user

  # Helper methods for display
  def shipping_name
    name
  end

  def shipping_full_address
    [
      shipping_address,
      shipping_apartment,
      shipping_city,
      shipping_state,
      shipping_postal_code,
      shipping_country,
    ].compact.join(", ")
  end

  def formatted_date
    created_at.strftime("%B %-d, %Y")
  end

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

  def send_status_update_email
    SendOrderStatusEmailJob.perform_later(self.id)
  end

  def inquiry_params
    params.require(:contact_inquiry).permit(:name, :email, :subject, :message)
  end

  def subscription_params
    params.require(:newsletter_subscription).permit(:email, :name, :active)
  end

  def newsletter_params
    params.require(:newsletter).permit(:title, :content, :status)
  end

  def response_params
    params.require(:contact_response).permit(:message)
  end

  private

  def set_total_from_cart
    return unless total.nil? && cart.present?

    # Calculate total including tax for each item in cart
    self.total = cart.cart_items.sum do |item|
      item.product.price_with_tax(item.price * item.quantity)
    end
  end

  def set_default_status
    self.status ||= :pending
  end

  def associate_with_user
    return if user.present? # Skip if user is already set
    return unless Current.user.present? # Skip if no current user

    self.user = Current.user
    self.name ||= Current.user.full_name
    self.email ||= Current.user.email
  end

  # Remove the duplicate product_orders creation
  # after_create :create_product_orders_from_cart

  # def create_product_orders_from_cart
  #  return unless cart.present?

  #  cart.cart_items.each do |cart_item|
  #    product_orders.create!(
  #      product: cart_item.product,
  #      quantity: cart_item.quantity,
  #      price: cart_item.price,
  #    )
  #  end
  # end
end

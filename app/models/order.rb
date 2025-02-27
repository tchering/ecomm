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
  after_commit :handle_status_change, on: [:create, :update]

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

  def handle_status_change
    Rails.logger.info "Order ##{id}: Checking status change. Current status: #{status}"
    Rails.logger.info "Order ##{id}: Status changed? #{saved_change_to_status?}"

    if saved_change_to_status?
      previous_status, new_status = saved_change_to_status
      Rails.logger.info "Order ##{id}: Status changed from #{previous_status} to #{new_status}"

      if new_status == "processing"
        Rails.logger.info "Order ##{id}: Starting stock reduction process"
        reduce_stock_quantities
      end
    end
  end

  def reduce_stock_quantities
    # Get or create system user for stock movements
    system_user = User.find_by(email: "system@example.com")
    if system_user.nil?
      password = SecureRandom.hex(10)
      system_user = User.create!(
        email: "system@example.com",
        password: password,
        password_confirmation: password,
        confirmed_at: Time.current,
      )
    end

    product_orders.includes(:product).each do |product_order|
      product = product_order.product
      quantity_needed = product_order.quantity

      Rails.logger.info "Order ##{id}: Processing product ##{product.id}, need #{quantity_needed} units"

      # Get all stocks for this product that have quantity > 0, ordered by quantity ascending
      available_stocks = product.stocks.where("quantity > 0").order(quantity: :asc).to_a
      total_available = available_stocks.sum(&:quantity)

      Rails.logger.info "Order ##{id}: Found #{available_stocks.count} warehouses with total stock #{total_available}"

      if total_available < quantity_needed
        Rails.logger.error "Order ##{id}: Insufficient stock for product ##{product.id}. Need #{quantity_needed}, have #{total_available}"
        next
      end

      available_stocks.each do |stock|
        break if quantity_needed <= 0

        original_quantity = stock.quantity
        quantity_to_reduce = [stock.quantity, quantity_needed].min

        Rails.logger.info "Order ##{id}: Reducing #{quantity_to_reduce} units from warehouse #{stock.warehouse_id} (had #{original_quantity})"

        begin
          ActiveRecord::Base.transaction do
            # Lock the stock record to prevent race conditions
            stock.lock!

            # Create a stock movement record
            StockMovement.record_movement(
              product,
              stock.warehouse,
              quantity_to_reduce,
              "reduction",
              system_user,
              "Order ##{id} processing - Stock reduced"
            )

            # Update the stock quantity
            stock.update!(quantity: stock.quantity - quantity_to_reduce)
          end

          quantity_needed -= quantity_to_reduce
          Rails.logger.info "Order ##{id}: Successfully reduced stock. Remaining needed: #{quantity_needed}"
        rescue => e
          Rails.logger.error "Order ##{id}: Failed to reduce stock: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
          next
        end
      end
    end
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

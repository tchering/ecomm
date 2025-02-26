class Product < ApplicationRecord
  belongs_to :category
  has_many_attached :images
  has_many :stocks, dependent: :destroy
  has_many :stock_movements
  has_many :warehouses, through: :stocks
  has_many :product_orders
  has_many :orders, through: :product_orders

  # Review relationships
  has_many :reviews, dependent: :destroy
  has_many :reviewers, through: :reviews, source: :user

  validates :tax_rate, numericality: {
                         greater_than_or_equal_to: 0,
                         less_than_or_equal_to: 100,
                         allow_nil: true,
                       }

  after_create :initialize_stock_records

  # Returns the effective tax rate for this product
  # Uses product's tax_rate if set, otherwise falls back to category's tax_rate
  def effective_tax_rate
    tax_rate.present? ? tax_rate : (category&.tax_rate || 0)
  end

  # Calculate tax amount for a given price
  def calculate_tax(price)
    price * (effective_tax_rate / 100.0)
  end

  # Calculate total price including tax
  def price_with_tax(price)
    price + calculate_tax(price)
  end

  # Review statistics
  def average_rating
    reviews.approved.average(:rating) || 0
  end

  def rating_distribution
    reviews.approved.group(:rating).count
  end

  def total_reviews_count
    reviews.approved.count
  end

  def reviews_by_rating(rating)
    reviews.approved.where(rating: rating)
  end

  def recent_reviews(limit = 5)
    reviews.approved.most_recent.limit(limit)
  end

  def top_rated_reviews(limit = 5)
    reviews.approved.highest_rating.limit(limit)
  end

  # Check if user can review
  def can_be_reviewed_by?(user)
    user && !reviews.exists?(user_id: user.id)
  end

  # Check if the product is in stock (has at least one stock record with quantity > 0)
  def in_stock?
    stocks.where("quantity > 0").exists?
  end

  # Get the total quantity available across all warehouses
  def total_stock_quantity
    stocks.sum(:quantity)
  end

  # Check if the product is low on stock (below reorder level)
  def low_stock?
    stocks.any? { |stock| stock.quantity > 0 && stock.quantity <= stock.reorder_level }
  end

  # Check if the product is out of stock
  def out_of_stock?
    !in_stock?
  end

  # Get the stock status as a string
  def stock_status
    if out_of_stock?
      "Out of Stock"
    elsif low_stock?
      "Low Stock"
    else
      "In Stock"
    end
  end

  private

  # Initialize stock records for all warehouses when a product is created
  def initialize_stock_records
    # Get all warehouses
    warehouses = Warehouse.all
    return if warehouses.empty?

    # Create a system user for stock movements if needed
    system_user = User.find_by(email: "system@example.com")
    if system_user.nil?
      # Generate a random password and use the same for confirmation
      password = SecureRandom.hex(10)
      system_user = User.create!(
        email: "system@example.com",
        password: password,
        password_confirmation: password,
      )
    end

    # Create a stock record for each warehouse with 0 quantity
    warehouses.each do |warehouse|
      stock = self.stocks.create!(
        warehouse: warehouse,
        quantity: 0,
        reorder_level: 10,
      )

      # Record the stock movement
      StockMovement.record_movement(
        self,
        warehouse,
        0,
        "addition",
        system_user,
        "Initial stock setup (automated)"
      )
    end
  end
end

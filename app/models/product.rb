class Product < ApplicationRecord
  belongs_to :category
  has_many_attached :images
  has_many :stocks, dependent: :destroy
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

  def total_stock
    stocks.sum(:quantity)
  end

  def in_stock?
    total_stock > 0
  end

  def low_stock?
    stocks.any? { |stock| stock.quantity > 0 && stock.quantity < stock.reorder_level }
  end

  def stock_status
    if !in_stock?
      "out_of_stock"
    elsif low_stock?
      "low_stock"
    else
      "in_stock"
    end
  end
end

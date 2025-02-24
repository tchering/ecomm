class Review < ApplicationRecord
  # Relationships
  belongs_to :user
  belongs_to :product
  has_many_attached :images

  # Validations
  validates :rating, presence: true,
                     numericality: { only_integer: true,
                                     greater_than_or_equal_to: 1,
                                     less_than_or_equal_to: 5 }
  validates :title, length: { maximum: 100 }
  validates :body, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :user_id, presence: true
  validates :product_id, presence: true

  # Scopes for easy filtering
  scope :approved, -> { where(approved: true) }
  scope :pending_approval, -> { where(approved: false) }
  scope :most_recent, -> { order(created_at: :desc) }
  scope :highest_rating, -> { order(rating: :desc) }
  scope :lowest_rating, -> { order(rating: :asc) }

  # Calculate helpful score
  def helpful_score
    helpful_votes - unhelpful_votes
  end

  # Check if user can modify the review
  def can_be_modified_by?(user)
    user && (user.id == user_id || user.admin?)
  end
end

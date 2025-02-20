class Faq < ApplicationRecord
  validates :question, presence: true, uniqueness: true
  validates :answer, presence: true
  validates :category, presence: true

  # Define common categories
  CATEGORIES = [
    "Orders",
    "Shipping",
    "Returns & Refunds",
    "Product Information",
    "Account & Security",
    "Payment",
    "General",
  ].freeze

  validates :category, inclusion: { in: CATEGORIES }

  # Scopes for easier querying
  scope :by_category, ->(category) { where(category: category).order(:question) }
  scope :search, ->(query) {
          where("question ILIKE ? OR answer ILIKE ?", "%#{query}%", "%#{query}%")
        }

  # Returns the most relevant FAQ for a given query
  def self.find_relevant(query)
    search(query).first
  end
end

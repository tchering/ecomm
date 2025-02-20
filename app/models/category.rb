class Category < ApplicationRecord
  has_one_attached :image
  has_many :products

  validates :tax_rate, presence: true,
                       numericality: {
                         greater_than_or_equal_to: 0,
                         less_than_or_equal_to: 100,
                       }
end

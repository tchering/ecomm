class ProductOrder < ApplicationRecord
  belongs_to :product
  belongs_to :order

  validates :quantity, numericality: { greater_than: 0 }
  validates :price, presence: true
end

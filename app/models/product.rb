class Product < ApplicationRecord
  belongs_to :category
  has_many_attached :images
  has_many :stocks, dependent: :destroy
  has_many :product_orders
  has_many :orders, through: :product_orders
end

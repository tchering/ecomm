class Order < ApplicationRecord
  validates :name, :email, :address, :status, presence: true

  has_many :product_orders
  has_many :products, through: :product_orders
  # STATUS = ["pending", "processing", "shipped", "delivered"]

  # validates :status, inclusion: { in: STATUS }

  enum status: { pending: 0, processing: 1, shipped: 2, delivered: 3, cancelled: 4 }
end

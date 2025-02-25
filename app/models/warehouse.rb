class Warehouse < ApplicationRecord
  has_many :stocks, dependent: :destroy
  has_many :products, through: :stocks

  validates :name, presence: true, uniqueness: true
  validates :location, presence: true

  def total_products
    stocks.count
  end

  def total_items
    stocks.sum(:quantity)
  end

  def low_stock_items
    stocks.low_stock.count
  end

  def out_of_stock_items
    stocks.out_of_stock.count
  end
end

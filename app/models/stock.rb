class Stock < ApplicationRecord
  belongs_to :product
  belongs_to :warehouse

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :reorder_level, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :warehouse_id, uniqueness: { scope: :product_id, message: "already has stock for this product" }

  scope :low_stock, -> { where("quantity < reorder_level AND quantity > 0") }
  scope :out_of_stock, -> { where(quantity: 0) }
  scope :in_stock, -> { where("quantity > 0") }

  def status
    if quantity <= 0
      "out_of_stock"
    elsif quantity < reorder_level
      "low_stock"
    else
      "in_stock"
    end
  end
end

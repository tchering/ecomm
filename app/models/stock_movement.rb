class StockMovement < ApplicationRecord
  belongs_to :product
  belongs_to :warehouse
  belongs_to :user, optional: true

  validates :quantity, presence: true, numericality: { only_integer: true }
  validates :movement_type, presence: true, inclusion: { in: %w[addition reduction transfer adjustment] }

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :additions, -> { where(movement_type: "addition") }
  scope :reductions, -> { where(movement_type: "reduction") }
  scope :transfers, -> { where(movement_type: "transfer") }
  scope :adjustments, -> { where(movement_type: "adjustment") }

  # Get movements for a specific product
  scope :for_product, ->(product_id) { where(product_id: product_id) }

  # Get movements for a specific warehouse
  scope :for_warehouse, ->(warehouse_id) { where(warehouse_id: warehouse_id) }

  # Get movements by date range
  scope :date_range, ->(start_date, end_date) { where(created_at: start_date.beginning_of_day..end_date.end_of_day) }

  # Get movements by user
  scope :by_user, ->(user_id) { where(user_id: user_id) }

  def self.movement_types
    %w[addition reduction transfer adjustment]
  end

  def self.record_movement(product, warehouse, quantity, movement_type, user = nil, notes = nil)
    create(
      product: product,
      warehouse: warehouse,
      quantity: quantity,
      movement_type: movement_type,
      user: user,
      notes: notes,
    )
  end
end

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
    # Handle the case when user is an Admin but the association expects a User
    if user.is_a?(Admin)
      # Try to find a corresponding User record or use a system user
      system_user = User.find_by(email: user.email) ||
                    User.find_by(email: "system@example.com") ||
                    User.first

      # If we still don't have a valid User, create one
      if system_user.nil?
        # Create a system user if none exists
        system_user = User.create!(
          email: "system@example.com",
          password: SecureRandom.hex(10),
          password_confirmation: SecureRandom.hex(10),
          confirmed_at: Time.current,
        ) rescue nil
      end

      user = system_user
    elsif user.nil?
      # If no user is provided, find or create a system user
      user = User.find_by(email: "system@example.com") || User.first

      # If we still don't have a valid User, create one
      if user.nil?
        # Create a system user if none exists
        user = User.create!(
          email: "system@example.com",
          password: SecureRandom.hex(10),
          password_confirmation: SecureRandom.hex(10),
          confirmed_at: Time.current,
        ) rescue nil
      end
    end

    # Create the stock movement with the user (which should now be a User object)
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

class Address < ApplicationRecord
  belongs_to :user

  validates :street_address, :city, :state, :postal_code, :country, presence: true

  # Ensure only one default address per user
  validates :is_default, uniqueness: { scope: :user_id }, if: :is_default?

  # Callback to handle default address logic
  before_save :handle_default_address

  private

  def handle_default_address
    # If this is being set as default, unset any other default addresses for this user
    if is_default? && is_default_changed?
      user.addresses.where.not(id: id).update_all(is_default: false)
    end

    # If this is the user's first address, make it default
    if user.addresses.none?
      self.is_default = true
    end
  end
end

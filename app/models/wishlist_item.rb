class WishlistItem < ApplicationRecord
  belongs_to :wishlist
  belongs_to :product

  # Ensure a product can only be in a wishlist once
  validates :product_id, uniqueness: { scope: :wishlist_id }
end

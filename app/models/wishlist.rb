class Wishlist < ApplicationRecord
  belongs_to :user
  has_many :wishlist_items, dependent: :destroy
  has_many :products, through: :wishlist_items

  # Method to check if a product is in the wishlist
  def includes_product?(product)
    products.include?(product)
  end

  # Method to toggle a product in the wishlist
  def toggle_product(product)
    if includes_product?(product)
      wishlist_items.find_by(product: product).destroy
    else
      wishlist_items.create(product: product)
    end
  end
end

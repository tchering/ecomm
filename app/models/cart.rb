class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  TAX_RATE = 0.13 # 13% tax rate

  def add_product(product, quantity = 1)
    current_item = cart_items.find_by(product: product)

    if current_item
      current_item.quantity += quantity
    else
      current_item = cart_items.build(product: product, price: product.price, quantity: quantity)
    end

    current_item
  end

  def subtotal
    cart_items.to_a.sum(&:total_price)
  end

  def tax
    (subtotal * TAX_RATE).round(2)
  end

  def total
    subtotal + tax
  end

  def total_price
    total
  end

  def total_items
    cart_items.sum(:quantity)
  end
end

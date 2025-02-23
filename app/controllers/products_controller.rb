class ProductsController < ApplicationController
  def show
    @product = Product.find(params[:id])
    @cart_item = current_cart.cart_items.find_by(product: @product) if current_cart
  end
end

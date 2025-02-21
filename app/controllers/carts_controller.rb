class CartsController < ApplicationController
  include CurrentCart
  before_action :set_cart

  def show
    @cart_items = @cart.cart_items.includes(product: { images_attachments: :blob })
  end

  def destroy
    @cart.destroy
    session[:cart_id] = nil
    redirect_to root_path, notice: "Your cart has been cleared."
  end
end

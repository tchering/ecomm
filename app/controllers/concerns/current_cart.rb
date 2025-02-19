module CurrentCart
  extend ActiveSupport::Concern

  private

  def set_cart
    @cart = Cart.find(session[:cart_id])
  rescue ActiveRecord::RecordNotFound
    @cart = Cart.create
    session[:cart_id] = @cart.id
  end

  def current_cart
    set_cart unless @cart
    @cart
  end
end

class CartsController < ApplicationController
  include CurrentCart

  def show
    @cart = current_cart
  end

  def destroy
    if @cart = current_cart
      @cart.destroy
      session[:cart_id] = nil
      
      respond_to do |format|
        format.html { redirect_to root_path, notice: 'Your cart has been cleared' }
        format.turbo_stream { 
          render turbo_stream: [
            turbo_stream.replace('cart_count',
              partial: 'layouts/cart_count',
              locals: { count: 0 }
            )
          ]
        }
      end
    else
      redirect_to root_path
    end
  end
end

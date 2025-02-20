class CheckoutsController < ApplicationController
  include CurrentCart
  before_action :set_cart

  def new
    if @cart.cart_items.empty?
      redirect_to cart_path, alert: "Your cart is empty"
      return
    end

    @order = Order.new
  end

  def create
    @order = Order.new(order_params)
    @order.status = "pending"

    # Start a transaction to ensure data consistency
    ActiveRecord::Base.transaction do
      if @order.save
        # Create ProductOrder records from cart items
        @cart.cart_items.each do |cart_item|
          ProductOrder.create!(
            order: @order,
            product: cart_item.product,
            quantity: cart_item.quantity,
            price: cart_item.price # Store the price at time of purchase
          )
        end

        # Clear the cart after successful order creation
        @cart.destroy
        session[:cart_id] = nil

        redirect_to order_confirmation_path(@order), notice: "Order was successfully placed!"
      else
        render :new, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  def confirmation
    @order = Order.find(params[:id])
  end

  private

  def order_params
    params.require(:order).permit(:name, :email, :address, :phone)
  end
end

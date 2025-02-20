class CheckoutsController < ApplicationController
  include CurrentCart
  before_action :set_cart
  before_action :set_current_cart

  def new
    if @cart.cart_items.empty?
      redirect_to cart_path, alert: "Your cart is empty"
      return
    end

    @order = Order.new
  end

  def create
    @order = Order.new(order_params)
    @order.status = :pending

    # Start a transaction to ensure data consistency
    ActiveRecord::Base.transaction do
      # First create the product orders to calculate the correct total
      @cart.cart_items.each do |cart_item|
        @order.product_orders.build(
          product: cart_item.product,
          quantity: cart_item.quantity,
          price: cart_item.price,
        )
      end

      # Set the total after building product orders
      @order.total = @order.total_with_tax

      if @order.save
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

  def set_current_cart
    Current.cart = @cart
  end
end

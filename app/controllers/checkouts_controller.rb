class CheckoutsController < ApplicationController
  include CurrentCart
  before_action :set_cart
  before_action :set_current_cart
  before_action :ensure_cart_not_empty, only: [:new, :create]

  def new
    @order = Order.new

    # Pre-fill address if user is logged in and has a default address
    if user_signed_in? && current_user.default_address.present?
      @order.assign_attributes(
        email: current_user.email,
        name: current_user.full_name,
        shipping_address: current_user.default_address.street_address,
        shipping_apartment: current_user.default_address.apartment,
        shipping_city: current_user.default_address.city,
        shipping_state: current_user.default_address.state,
        shipping_postal_code: current_user.default_address.postal_code,
        shipping_country: current_user.default_address.country,
      )
    end
  end

  def create
    @order = Order.new(order_params)
    @order.user = current_user if user_signed_in?

    # If using a saved address
    if params[:address_choice] == "saved" && params[:saved_address_id].present?
      saved_address = current_user.addresses.find(params[:saved_address_id])
      @order.assign_attributes(
        shipping_address: saved_address.street_address,
        shipping_apartment: saved_address.apartment,
        shipping_city: saved_address.city,
        shipping_state: saved_address.state,
        shipping_postal_code: saved_address.postal_code,
        shipping_country: saved_address.country,
      )
    end

    @order.cart = @cart

    # Create product orders from cart items
    if @order.save
      @cart.cart_items.each do |cart_item|
        @order.product_orders.create!(
          product: cart_item.product,
          quantity: cart_item.quantity,
          price: cart_item.price,
        )
      end

      # Handle address saving for logged-in users with new address
      if user_signed_in? && params[:address_choice] == "new" && params[:save_address] == "1"
        begin
          address = current_user.addresses.create!(
            street_address: @order.shipping_address,
            apartment: @order.shipping_apartment,
            city: @order.shipping_city,
            state: @order.shipping_state,
            postal_code: @order.shipping_postal_code,
            country: @order.shipping_country,
            is_default: params[:make_default_address] == "1",
          )

          flash[:notice] = if address.is_default?
              "Order was successfully created and shipping address saved as default."
            else
              "Order was successfully created and shipping address saved."
            end
        rescue ActiveRecord::RecordInvalid => e
          flash[:notice] = "Order was successfully created but there was an error saving the address: #{e.message}"
        end
      else
        flash[:notice] = "Order was successfully created."
      end

      # Clear the cart
      session.delete(:cart_id)
      redirect_to order_confirmation_path(@order)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def confirmation
    @order = Order.includes(product_orders: { product: { images_attachment: :blob } }).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Order not found"
  end

  private

  # Override set_cart from CurrentCart to include eager loading
  def set_cart
    @cart = Cart.includes(
      cart_items: {
        product: [
          :category,
          { images_attachments: :blob },
        ],
      },
    ).find(session[:cart_id])
  rescue ActiveRecord::RecordNotFound
    @cart = Cart.create
    session[:cart_id] = @cart.id
  end

  def order_params
    params.require(:order).permit(
      :email,
      :name,
      :phone,
      :shipping_address,
      :shipping_apartment,
      :shipping_city,
      :shipping_state,
      :shipping_postal_code,
      :shipping_country,
      :latitude,
      :longitude
    )
  end

  def set_current_cart
    Current.cart = @cart
  end

  def ensure_cart_not_empty
    if @cart.nil? || @cart.cart_items.empty?
      redirect_to cart_path, alert: "Your cart is empty."
    end
  end
end

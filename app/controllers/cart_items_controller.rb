class CartItemsController < ApplicationController
  include CurrentCart
  before_action :set_cart
  before_action :set_cart_item, only: [:update, :destroy]

  def create
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i || 1
    @cart_item = @cart.add_product(product, quantity)

    respond_to do |format|
      if @cart_item.save
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace('cart_count',
              partial: 'layouts/cart_count',
              locals: { count: @cart.total_items }
            ),
            turbo_stream.update('flash_messages',
              partial: 'shared/flash_message',
              locals: { message: 'Item added to cart', type: 'success' }
            )
          ]
        }
        format.html { redirect_back(fallback_location: root_path, notice: 'Item added to cart') }
      else
        format.html { redirect_back(fallback_location: root_path, alert: 'Error adding item to cart') }
      end
    end
  end

  def update
    respond_to do |format|
      if @cart_item.update(cart_item_params)
        @cart.reload # Ensure we have the latest cart data
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace(@cart_item,
              partial: 'cart_items/cart_item',
              locals: { cart_item: @cart_item }
            ),
            turbo_stream.replace('order_summary',
              partial: 'carts/order_summary',
              locals: { cart: @cart }
            ),
            turbo_stream.replace('cart_count',
              partial: 'layouts/cart_count',
              locals: { count: @cart.total_items }
            )
          ]
        }
        format.html { redirect_to cart_path(@cart), notice: 'Item quantity updated' }
      else
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace(@cart_item,
              partial: 'cart_items/cart_item',
              locals: { cart_item: @cart_item }
            ),
            turbo_stream.replace('order_summary',
              partial: 'carts/order_summary',
              locals: { cart: @cart }
            )
          ]
        }
        format.html { redirect_to cart_path(@cart), alert: 'Error updating quantity' }
      end
    end
  end

  def destroy
    @cart_item.destroy
    @cart.reload # Ensure we have the latest cart data

    respond_to do |format|
      if @cart.cart_items.empty?
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.update('cart_items', partial: 'carts/empty_cart'),
            turbo_stream.replace('order_summary',
              partial: 'carts/order_summary',
              locals: { cart: @cart }
            ),
            turbo_stream.replace('cart_count',
              partial: 'layouts/cart_count',
              locals: { count: 0 }
            )
          ]
        }
      else
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.remove(@cart_item),
            turbo_stream.replace('order_summary',
              partial: 'carts/order_summary',
              locals: { cart: @cart }
            ),
            turbo_stream.replace('cart_count',
              partial: 'layouts/cart_count',
              locals: { count: @cart.total_items }
            )
          ]
        }
      end
      format.html { redirect_to cart_path(@cart), notice: 'Item removed from cart' }
    end
  end

  private

  def set_cart_item
    @cart_item = @cart.cart_items.find(params[:id])
  end

  def cart_item_params
    params.require(:cart_item).permit(:quantity)
  end
end

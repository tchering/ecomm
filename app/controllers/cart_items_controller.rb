class CartItemsController < ApplicationController
  include CurrentCart
  include ActionView::RecordIdentifier
  before_action :set_cart
  before_action :set_cart_item, only: [:update, :destroy]

  def create
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i || 1
    @cart_item = @cart.add_product(product, quantity)

    respond_to do |format|
      if @cart_item.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("cart_count", partial: "layouts/cart_count"),
            turbo_stream.replace("cart-notice-product-#{product.id}") {
              render_to_string(partial: "cart_items/cart_notice", locals: { product: product, cart_item: @cart_item })
            },
          ]
        end
        format.html { redirect_back(fallback_location: root_path) }
      else
        format.turbo_stream { head :unprocessable_entity }
        format.html { redirect_back(fallback_location: root_path) }
      end
    end
  rescue StandardError => e
    respond_to do |format|
      format.turbo_stream { head :unprocessable_entity }
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  def update
    @cart_item.quantity = params[:quantity]

    respond_to do |format|
      if @cart_item.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("cart_count", partial: "layouts/cart_count"),
            turbo_stream.replace("cart-notice-product-#{@cart_item.product_id}") {
              render_to_string(partial: "cart_items/cart_notice", locals: { product: @cart_item.product, cart_item: @cart_item })
            },
            turbo_stream.replace("order_summary", partial: "carts/order_summary", locals: { cart: @cart }),
            turbo_stream.replace(dom_id(@cart_item), partial: "cart_items/cart_item", locals: { cart_item: @cart_item }),
          ]
        end
        format.html { redirect_back(fallback_location: root_path) }
      else
        format.turbo_stream { head :unprocessable_entity }
        format.html { redirect_back(fallback_location: root_path) }
      end
    end
  rescue StandardError => e
    respond_to do |format|
      format.turbo_stream { head :unprocessable_entity }
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  def destroy
    @cart_item = CartItem.find(params[:id])
    product = @cart_item.product
    cart_item_id = dom_id(@cart_item)
    @cart_item.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(cart_item_id),
          turbo_stream.replace("cart_count", partial: "layouts/cart_count"),
          turbo_stream.replace("cart-notice-product-#{product.id}", ""),
          turbo_stream.replace("order_summary", partial: "carts/order_summary", locals: { cart: @cart }),
        ]
      end
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  private

  def set_cart_item
    @cart_item = @cart.cart_items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.turbo_stream { head :not_found }
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  def cart_item_params
    params.require(:cart_item).permit(:quantity)
  end
end

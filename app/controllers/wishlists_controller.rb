class WishlistsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_wishlist_exists
  before_action :set_wishlist

  def show
    @wishlist_items = @wishlist.wishlist_items.includes(:product)
  end

  def toggle
    @product = Product.find(params[:product_id])
    was_in_wishlist = @wishlist.includes_product?(@product)
    @wishlist.toggle_product(@product)

    flash.now[:notice] = if was_in_wishlist
        "#{@product.title} has been removed from your wishlist"
      else
        "#{@product.title} has been added to your wishlist"
      end

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace("wishlist_icon_#{@product.id}",
                               partial: "wishlists/wishlist_icon",
                               locals: { product: @product }),
          turbo_stream.replace("wishlist_dropdown",
                               partial: "wishlists/wishlist_dropdown",
                               locals: { wishlist_items: @wishlist.wishlist_items.includes(:product) }),
          turbo_stream.update("flash-messages",
                              partial: "shared/flash"),
        ]
      }
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  private

  def ensure_wishlist_exists
    unless current_user.wishlist
      current_user.create_wishlist
    end
  end

  def set_wishlist
    @wishlist = current_user.wishlist
  end
end

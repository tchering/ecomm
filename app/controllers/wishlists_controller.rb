class WishlistsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_wishlist_exists
  before_action :set_wishlist

  def show
    @wishlist_items = @wishlist.wishlist_items.includes(product: { images_attachments: :blob })
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
      format.turbo_stream do
        render turbo_stream: [
          # Update all instances of this product's wishlist icon across the page
          turbo_stream.replace_all(".wishlist-icon-#{@product.id}",
                                   partial: "wishlists/wishlist_icon",
                                   locals: { product: @product }),

          # Update the wishlist dropdown content
          turbo_stream.replace("wishlist_dropdown",
                               partial: "wishlists/wishlist_dropdown",
                               locals: { wishlist_items: @wishlist.wishlist_items.includes(product: { images_attachments: :blob }) }),

          # Update the wishlist count in the header
          turbo_stream.replace("wishlist_count",
                               partial: "wishlists/wishlist_count",
                               locals: { count: @wishlist.wishlist_items.count }),

          # Show the flash message
          turbo_stream.update("flash-messages",
                              partial: "shared/flash"),
        ]
      end
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

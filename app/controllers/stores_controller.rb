class StoresController < ApplicationController
  include CurrentCart
  before_action :set_cart

  def index
    @categories = Category.includes(image_attachment: :blob)
    @products = if params[:category]
        Product.where(category_id: params[:category])
               .includes(:category, images_attachments: :blob)
      else
        Product.includes(:category, images_attachments: :blob)
      end

    if params[:category].present?
      @products = @products.where(category_id: params[:category])
    end

    @trending_products = Product.where(active: true)
      .includes(:category, images_attachments: :blob)
      .order(created_at: :desc)
      .limit(4)

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          "products-grid",
          partial: "products_grid",
          locals: { products: @products },
        )
      end
    end
  end

  def show
    @product = Product.includes(images_attachments: :blob).find(params[:id])
    @cart_item = @cart.cart_items.find_by(product: @product) if @cart
  end
end

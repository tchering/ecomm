class StoresController < ApplicationController
  def index
    @categories = Category.all
    @products = Product.where(active: true)

    if params[:category].present?
      @products = @products.where(category_id: params[:category])
    end

    @trending_products = Product.where(active: true).order(created_at: :desc).limit(4)

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          'products-grid',
          partial: 'products_grid',
          locals: { products: @products }
        )
      end
    end
  end

  def show
    @product = Product.find(params[:id])
  end
end

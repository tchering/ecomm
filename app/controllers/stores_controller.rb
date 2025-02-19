class StoresController < ApplicationController
  def index
    @products = Product.where(active: true)
    @trending_products = Product.where(active: true).order(created_at: :desc).limit(4)
  end

  def show
    @product = Product.find(params[:id])
  end
end

class Admin::StocksController < ApplicationController
  before_action :set_admin_stock, only: %i[ show edit update destroy ]
  layout "admin"

  # GET /admin/stocks or /admin/stocks.json
  def index
    @admin_stocks = Stock.all
  end

  # GET /admin/stocks/1 or /admin/stocks/1.json
  def show
  end

  # GET /admin/stocks/new
  def new
    #here params[:product_id] is passed from product/form.html.erb
    @product = Product.find(params[:product_id]) if params[:product_id]
    @admin_stock = Stock.new(product_id: @product.id)
  end

  # GET /admin/stocks/1/edit
  def edit
  end

  # POST /admin/stocks or /admin/stocks.json
  def create
    @admin_stock = Stock.new(admin_stock_params)

    respond_to do |format|
      if @admin_stock.save
        format.html { redirect_to admin_stocks_path, notice: "Stock was successfully created." }
        format.json { render :show, status: :created, location: @admin_stock }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @admin_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/stocks/1 or /admin/stocks/1.json
  def update
    respond_to do |format|
      if @admin_stock.update(admin_stock_params)
        format.html { redirect_to @admin_stock, notice: "Stock was successfully updated." }
        format.json { render :show, status: :ok, location: @admin_stock }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @admin_stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/stocks/1 or /admin/stocks/1.json
  def destroy
    @admin_stock.destroy!

    respond_to do |format|
      format.html { redirect_to admin_stocks_path, status: :see_other, notice: "Stock was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def by_product
    @product = Product.find(params[:product_id])
    @admin_stocks = @product.stocks
    render :index
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_admin_stock
    @admin_stock = Stock.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def admin_stock_params
    params.require(:stock).permit(:size, :quantity, :product_id)
  end
end

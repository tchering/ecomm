class Admin::StocksController < AdminController
  before_action :set_product, except: [:index]
  before_action :set_stock, only: [:edit, :update, :destroy]

  # GET /admin/stocks
  def index
    @stocks = Stock.includes(:product, :warehouse)
      .order(updated_at: :desc)
      .page(params[:page]).per(15)

    # Filter by product
    if params[:product_id].present?
      @stocks = @stocks.where(product_id: params[:product_id])
      @product = Product.find(params[:product_id])
    end

    # Filter by warehouse
    if params[:warehouse_id].present?
      @stocks = @stocks.where(warehouse_id: params[:warehouse_id])
    end

    # Filter by stock status
    case params[:status]
    when "low"
      @stocks = @stocks.low_stock
    when "out"
      @stocks = @stocks.out_of_stock
    when "in_stock"
      @stocks = @stocks.in_stock
    end

    # Search by product name or SKU
    if params[:search].present?
      @stocks = @stocks.joins(:product).where("products.title LIKE ? OR products.sku LIKE ?",
                                              "%#{params[:search]}%",
                                              "%#{params[:search]}%")
    end

    # Get all warehouses for the filter dropdown
    @warehouses = Warehouse.all
  end

  # GET /admin/products/:product_id/stocks
  def by_product
    @stocks = @product.stocks.includes(:warehouse)
    @warehouses = Warehouse.all

    # Get recent stock movements for this product
    @recent_movements = StockMovement.for_product(@product.id).recent.limit(10)
  end

  # GET /admin/products/:product_id/stocks/new
  def new
    @stock = @product.stocks.build
    @warehouses = Warehouse.all
  end

  # POST /admin/products/:product_id/stocks
  def create
    @stock = @product.stocks.build(stock_params)

    if @stock.save
      # Record the stock movement
      StockMovement.record_movement(
        @product,
        @stock.warehouse,
        @stock.quantity,
        "addition",
        current_user,
        "Initial stock setup"
      )

      redirect_to admin_product_stocks_path(product_id: @product.id),
                  notice: "Stock was successfully added."
    else
      @warehouses = Warehouse.all
      render :new
    end
  end

  # GET /admin/products/:product_id/stocks/:id/edit
  def edit
    @warehouses = Warehouse.all
  end

  # PATCH/PUT /admin/products/:product_id/stocks/:id
  def update
    old_quantity = @stock.quantity

    if @stock.update(stock_params)
      # Record the stock movement if quantity changed
      if old_quantity != @stock.quantity
        movement_type = old_quantity < @stock.quantity ? "addition" : "reduction"
        quantity_change = (old_quantity - @stock.quantity).abs

        StockMovement.record_movement(
          @product,
          @stock.warehouse,
          quantity_change,
          movement_type,
          current_user,
          "Stock updated from #{old_quantity} to #{@stock.quantity}"
        )
      end

      redirect_to admin_product_stocks_path(product_id: @product.id),
                  notice: "Stock was successfully updated."
    else
      @warehouses = Warehouse.all
      render :edit
    end
  end

  # DELETE /admin/products/:product_id/stocks/:id
  def destroy
    warehouse = @stock.warehouse
    quantity = @stock.quantity

    if @stock.destroy
      # Record the stock movement
      if quantity > 0
        StockMovement.record_movement(
          @product,
          warehouse,
          quantity,
          "reduction",
          current_user,
          "Stock removed from warehouse"
        )
      end

      redirect_to admin_product_stocks_path(product_id: @product.id),
                  notice: "Stock was successfully removed."
    else
      redirect_to admin_product_stocks_path(product_id: @product.id),
                  alert: "Failed to remove stock."
    end
  end

  # POST /admin/products/:product_id/stocks/adjust
  def adjust
    @stock = @product.stocks.find_by(warehouse_id: params[:warehouse_id])
    adjustment = params[:adjustment].to_i

    if @stock
      old_quantity = @stock.quantity
      new_quantity = old_quantity + adjustment
      new_quantity = 0 if new_quantity < 0

      if @stock.update(quantity: new_quantity)
        # Record the stock movement
        movement_type = adjustment > 0 ? "addition" : "reduction"

        StockMovement.record_movement(
          @product,
          @stock.warehouse,
          adjustment.abs,
          movement_type,
          current_user,
          params[:notes].presence || "Manual adjustment from #{old_quantity} to #{new_quantity}"
        )

        flash[:notice] = "Stock adjusted successfully."
      else
        flash[:alert] = "Failed to adjust stock: #{@stock.errors.full_messages.join(", ")}"
      end
    else
      flash[:alert] = "Stock record not found for this warehouse."
    end

    redirect_to admin_product_stocks_path(product_id: @product.id)
  end

  # GET /admin/products/:product_id/stocks/movements
  def movements
    @movements = StockMovement.for_product(@product.id).recent.page(params[:page]).per(20)
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_stock
    @stock = @product.stocks.find(params[:id])
  end

  def stock_params
    params.require(:stock).permit(:warehouse_id, :quantity, :reorder_level)
  end
end

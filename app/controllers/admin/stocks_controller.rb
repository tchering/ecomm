class Admin::StocksController < AdminController
  before_action :set_product, except: [:index, :restock]
  before_action :set_stock, only: [:edit, :update, :destroy]

  # GET /admin/stocks
  def index
    @stocks = Stock.includes(:warehouse, product: { images_attachments: :blob })
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
    @recent_movements = StockMovement.for_product(@product.id).includes(:user, :warehouse).recent.limit(10)
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
        current_user, # Ensure current_user is correctly passed
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
          current_user, # Ensure current_user is correctly passed
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
          current_user, # Ensure current_user is correctly passed
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
          current_user, # Ensure current_user is correctly passed
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

  # POST /admin/stocks/:id/restock
  def restock
    @stock = Stock.find_by(id: params[:id])

    if @stock
      @product = @stock.product

      # Default to adding 10 items or use the reorder_level as the target
      quantity_to_add = params[:quantity].present? ? params[:quantity].to_i : 10

      old_quantity = @stock.quantity
      new_quantity = old_quantity + quantity_to_add

      if @stock.update(quantity: new_quantity)
        # Record the stock movement - ensure current_user is passed
        StockMovement.record_movement(
          @product,
          @stock.warehouse,
          quantity_to_add,
          "addition",
          current_user, # Make sure this is always passed
          "Restocked from #{old_quantity} to #{new_quantity}"
        )

        respond_to do |format|
          format.html {
            redirect_to by_product_admin_product_stocks_path(product_id: @product.id),
              notice: "#{@product.title} has been restocked with #{quantity_to_add} units."
          }
          format.turbo_stream {
            redirect_to by_product_admin_product_stocks_path(product_id: @product.id),
              notice: "#{@product.title} has been restocked with #{quantity_to_add} units."
          }
        end
      else
        respond_to do |format|
          format.html {
            redirect_to admin_stocks_path,
              alert: "Failed to restock: #{@stock.errors.full_messages.join(", ")}"
          }
          format.turbo_stream {
            redirect_to admin_stocks_path,
              alert: "Failed to restock: #{@stock.errors.full_messages.join(", ")}"
          }
        end
      end
    else
      respond_to do |format|
        format.html {
          redirect_to admin_stocks_path,
            alert: "Stock record not found."
        }
        format.turbo_stream {
          redirect_to admin_stocks_path,
            alert: "Stock record not found."
        }
      end
    end
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

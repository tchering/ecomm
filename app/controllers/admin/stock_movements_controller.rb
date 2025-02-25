class Admin::StockMovementsController < AdminController
  # GET /admin/stock_movements
  def index
    @movements = StockMovement.includes(:product, :warehouse, :user).recent

    # Filter by product
    if params[:product_id].present?
      @movements = @movements.for_product(params[:product_id])
    end

    # Filter by warehouse
    if params[:warehouse_id].present?
      @movements = @movements.for_warehouse(params[:warehouse_id])
    end

    # Filter by movement type
    if params[:movement_type].present?
      @movements = @movements.where(movement_type: params[:movement_type])
    end

    # Filter by date range
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date]) rescue nil
      end_date = Date.parse(params[:end_date]) rescue nil

      if start_date && end_date
        @movements = @movements.date_range(start_date, end_date)
      end
    end

    # Pagination
    @movements = @movements.page(params[:page]).per(20)

    # Get all products and warehouses for the filter dropdowns
    @products = Product.all.order(:title)
    @warehouses = Warehouse.all.order(:name)
    @movement_types = StockMovement.movement_types
  end

  # GET /admin/stock_movements/:id
  def show
    @movement = StockMovement.includes(:product, :warehouse, :user).find(params[:id])
  end
end

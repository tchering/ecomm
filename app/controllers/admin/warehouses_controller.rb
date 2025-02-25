class Admin::WarehousesController < AdminController
  before_action :set_warehouse, only: [:show, :edit, :update, :destroy]

  # GET /admin/warehouses
  def index
    @warehouses = Warehouse.all.order(name: :asc)
  end

  # GET /admin/warehouses/1
  def show
    @stocks = @warehouse.stocks.includes(:product)
                       .order('products.title')
                       .page(params[:page]).per(15)
  end

  # GET /admin/warehouses/new
  def new
    @warehouse = Warehouse.new
  end

  # GET /admin/warehouses/1/edit
  def edit
  end

  # POST /admin/warehouses
  def create
    @warehouse = Warehouse.new(warehouse_params)

    if @warehouse.save
      redirect_to admin_warehouse_path(@warehouse), notice: 'Warehouse was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /admin/warehouses/1
  def update
    if @warehouse.update(warehouse_params)
      redirect_to admin_warehouse_path(@warehouse), notice: 'Warehouse was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /admin/warehouses/1
  def destroy
    if @warehouse.stocks.any?
      redirect_to admin_warehouses_path, alert: 'Cannot delete warehouse with existing stock. Please move or delete stock first.'
    else
      @warehouse.destroy
      redirect_to admin_warehouses_path, notice: 'Warehouse was successfully deleted.'
    end
  end

  private
    def set_warehouse
      @warehouse = Warehouse.find(params[:id])
    end

    def warehouse_params
      params.require(:warehouse).permit(:name, :location, :description)
    end
end

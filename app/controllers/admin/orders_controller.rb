class Admin::OrdersController < AdminController
  include Admin::OrdersHelper
  before_action :set_order, only: %i[ show edit update destroy ]

  # GET /admin/orders or /admin/orders.json
  def index
    @orders = Order.all.order(created_at: :desc).page(params[:page]).per(10)
  end

  # GET /admin/orders/1 or /admin/orders/1.json
  def show
  end

  # GET /admin/orders/new
  def new
    @order = Order.new
  end

  # GET /admin/orders/1/edit
  def edit
  end

  # POST /admin/orders or /admin/orders.json
  def create
    @order = Order.new(order_params)
    @order.status = "pending"  #by default

    respond_to do |format|
      if @order.save
        format.html { redirect_to admin_orders_path, notice: "Order was successfully created." }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/orders/1 or /admin/orders/1.json
  def update
    if @order.update(order_params)
      respond_to do |format|
        format.html {
          flash[:notice] = "Order status has been updated to #{@order.status.titleize}"
          redirect_to admin_order_path(@order)
        }
        format.json { render json: { status: :ok } }
      end
    else
      respond_to do |format|
        format.html {
          flash[:alert] = "Failed to update order status"
          redirect_to admin_order_path(@order)
        }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/orders/1 or /admin/orders/1.json
  def destroy
    @order.destroy!

    respond_to do |format|
      format.html { redirect_to admin_orders_path, status: :see_other, notice: "Order was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  #These below are custom routes to filter the index according to status
  def by_status
    @status = params[:status]
    @orders = Order.where(status: @status).order(created_at: :desc).page(params[:page]).per(10)
    render :index
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.includes(product_orders: { product: { images_attachments: :blob } }).find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def order_params
    params.require(:order).permit(:status, :name, :email, :address, :total, :phone)
  end
end

class Admin::OrdersController < ApplicationController
  include Admin::OrdersHelper
  layout "admin"
  before_action :set_admin_order, only: %i[ show edit update destroy ]

  # GET /admin/orders or /admin/orders.json
  def index
    @admin_orders = Order.all
  end

  # GET /admin/orders/1 or /admin/orders/1.json
  def show
  end

  # GET /admin/orders/new
  def new
    @admin_order = Order.new
  end

  # GET /admin/orders/1/edit
  def edit
  end

  # POST /admin/orders or /admin/orders.json
  def create
    @admin_order = Order.new(admin_order_params)
    @admin_order.status = "pending"  #by default

    respond_to do |format|
      if @admin_order.save
        format.html { redirect_to admin_orders_path, notice: "Order was successfully created." }
        format.json { render :show, status: :created, location: @admin_order }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @admin_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/orders/1 or /admin/orders/1.json
  def update
    @admin_order = Order.find(params[:id])
    if @admin_order.update(order_params)
      respond_to do |format|
        format.html {
          flash[:notice] = "Order status has been updated to #{@admin_order.status.titleize}"
          redirect_to admin_order_path(@admin_order)
        }
        format.json { render json: { status: :ok } }
      end
    else
      respond_to do |format|
        format.html {
          flash[:alert] = "Failed to update order status"
          redirect_to admin_order_path(@admin_order)
        }
        format.json { render json: @admin_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/orders/1 or /admin/orders/1.json
  def destroy
    @admin_order.destroy!

    respond_to do |format|
      format.html { redirect_to admin_orders_path, status: :see_other, notice: "Order was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  #These below are custom routes to filter the index according to status
  def by_status
    @admin_orders = Order.where(status: params[:status])
    respond_to do |format|
      format.html { render :index }
      format.turbo_stream {
        render turbo_stream: turbo_stream.update("admin_orders_body",
                                                 partial: "admin/orders/order",
                                                 collection: @admin_orders,
                                                 as: :order)
      }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_admin_order
    @admin_order = Order.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def order_params
    params.require(:order).permit(:status, :name, :email, :address)
  end
end

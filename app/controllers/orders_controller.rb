class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :invoice]

  def index
    @orders = current_user.orders.includes(product_orders: { product: { images_attachments: :blob } })

    # Filter by time period
    case params[:time_period]
    when "3_months"
      @orders = @orders.where("created_at >= ?", 3.months.ago)
    when "6_months"
      @orders = @orders.where("created_at >= ?", 6.months.ago)
    when "1_year"
      @orders = @orders.where("created_at >= ?", 1.year.ago)
    end

    # Filter by status
    @orders = @orders.where(status: params[:status]) if params[:status].present?

    # Sort by most recent first
    @orders = @orders.order(created_at: :desc)
  end

  def show
  end

  def invoice
    respond_to do |format|
      format.pdf do
        pdf = OrderInvoicePdf.new(@order)
        send_data pdf.render,
                  filename: "order_#{@order.id}_invoice.pdf",
                  type: "application/pdf",
                  disposition: "inline"
      end
    end
  end

  private

  def set_order
    @order = current_user.orders
      .includes(product_orders: { product: { images_attachments: :blob } })
      .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to orders_path, alert: "Order not found"
  end
end

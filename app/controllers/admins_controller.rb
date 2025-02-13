class AdminsController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!

  def dashboard
    #Total lifetime sales
    @total_sales = Order.sum(:total)

    #Total number of orders
    @total_orders = Order.count

    #Average order value
    # @average_order_value = @total_sales / @total_orders
    @average_order_value = Order.average(:total)

    #Sales for today
    @today_sales = Order.where("Date(created_at) = ?", Date.today).sum(:total)
    @today_orders_count = Order.where("Date(created_at) = ?", Date.today).count

    #Sales of this week
    @week_sales = Order.where("Date(created_at) = ?", 1.week.ago).sum(:total)
    @week_orders_count = Order.where("Date(created_at) = ?", 1.week.ago).count

    #Sales of this month
    @month_sales = Order.where("Date(created_at) = ?", 1.month.ago).sum(:total)
    @month_orders_count = Order.where("Date(created_at) = ?", 1.month.ago).count
  end
end

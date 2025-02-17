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

    #Sales of this week (last 7 days)
    @week_sales = Order.where("created_at >= ?", 1.week.ago).sum(:total)
    @week_orders_count = Order.where("created_at >= ?", 1.week.ago).count

    #Sales of this month (last 30 days)
    @month_sales = Order.where("created_at >= ?", 1.month.ago).sum(:total)
    @month_orders_count = Order.where("created_at >= ?", 1.month.ago).count

    # Daily sales for the last 7 days
    @daily_sales = (0..6).map do |days_ago|
      date = Date.today - days_ago.days
      {
        date: date,
        sales: Order.where("Date(created_at) = ?", date).sum(:total),
        orders: Order.where("Date(created_at) = ?", date).count,
      }
    end.reverse
  end
end

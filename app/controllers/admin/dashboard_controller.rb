class Admin::DashboardController < AdminController
  def index
    # Total lifetime sales
    @total_sales = Order.sum(:total)

    # Total number of orders
    @total_orders = Order.count

    # Average order value
    @average_order_value = @total_orders > 0 ? @total_sales / @total_orders : 0

    # Total number of users
    @total_users = User.count

    # Total number of products
    @total_products = Product.count

    # Orders by status
    @pending_orders = Order.where(status: "pending").count
    @processing_orders = Order.where(status: "processing").count
    @shipped_orders = Order.where(status: "shipped").count
    @delivered_orders = Order.where(status: "delivered").count
    @cancelled_orders = Order.where(status: "cancelled").count

    # Sales for today
    @today_sales = Order.where("Date(created_at) = ?", Date.today).sum(:total)
    @today_orders_count = Order.where("Date(created_at) = ?", Date.today).count

    # Sales of this week (last 7 days)
    @week_sales = Order.where("created_at >= ?", 1.week.ago).sum(:total)
    @week_orders_count = Order.where("created_at >= ?", 1.week.ago).count

    # Sales of this month (last 30 days)
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

    # Top selling products (last 30 days)
    @top_products = ProductOrder.joins(:product)
      .where("product_orders.created_at >= ?", 30.days.ago)
      .group("products.id", "products.title")
      .select("products.id, products.title, SUM(product_orders.quantity) as total_quantity")
      .order("total_quantity DESC")
      .limit(5)

    # New users in the last 30 days
    @new_users_count = User.where("created_at >= ?", 30.days.ago).count

    # Inventory statistics
    @total_stock_items = Stock.sum(:quantity)
    @low_stock_count = Stock.low_stock.count
    @out_of_stock_count = Stock.out_of_stock.count

    # Low stock products (less than reorder level)
    @low_stock_products = Product.joins(:stocks)
      .where("stocks.quantity < stocks.reorder_level")
      .group("products.id", "products.title")
      .select("products.id, products.title, SUM(stocks.quantity) as total_stock")
      .order(Arel.sql("SUM(stocks.quantity) ASC"))
      .limit(5)

    # Warehouses with most items
    @top_warehouses = Warehouse.joins(:stocks)
      .group("warehouses.id", "warehouses.name")
      .select("warehouses.id, warehouses.name, SUM(stocks.quantity) as total_items")
      .order(Arel.sql("SUM(stocks.quantity) DESC"))
      .limit(5)
  end

  def inventory
    # Inventory statistics
    @total_stock_items = Stock.sum(:quantity)
    @low_stock_count = Stock.low_stock.count
    @out_of_stock_count = Stock.out_of_stock.count

    # Low stock products (less than reorder level)
    @low_stock_products = Product.joins(:stocks)
      .where("stocks.quantity < stocks.reorder_level")
      .group("products.id", "products.title")
      .select("products.id, products.title, SUM(stocks.quantity) as total_stock")
      .order(Arel.sql("SUM(stocks.quantity) ASC"))
      .limit(10)

    # Warehouses with most items
    @top_warehouses = Warehouse.joins(:stocks)
      .group("warehouses.id", "warehouses.name")
      .select("warehouses.id, warehouses.name, SUM(stocks.quantity) as total_items")
      .order(Arel.sql("SUM(stocks.quantity) DESC"))
      .limit(10)

    # Products with no stock
    @out_of_stock_products = Product.left_joins(:stocks)
      .group("products.id", "products.title")
      .having("SUM(COALESCE(stocks.quantity, 0)) = 0 OR COUNT(stocks.id) = 0")
      .select("products.id, products.title")
      .limit(10)

    # Recent stock movements
    @recent_stock_movements = StockMovement.includes(:product, :warehouse, :user)
      .order(created_at: :desc)
      .limit(10)
  end
end

namespace :stock do
  desc "Initialize stock records for all products that don't have them"
  task initialize: :environment do
    # Get all products without stock records
    products_without_stock = Product.left_joins(:stocks).where(stocks: { id: nil }).distinct

    # Get all warehouses
    warehouses = Warehouse.all

    if warehouses.empty?
      puts "Error: No warehouses found. Please create at least one warehouse first."
      exit
    end

    # Default warehouse to use (first one)
    default_warehouse = warehouses.first

    # Initialize counter
    initialized_count = 0

    # Create a system user for stock movements if needed
    system_user = User.find_by(email: "system@example.com")
    if system_user.nil?
      # Generate a random password and use the same for confirmation
      password = SecureRandom.hex(10)
      system_user = User.create!(
        email: "system@example.com",
        password: password,
        password_confirmation: password,
      )
      puts "Created system user for stock movements"
    end

    # Process each product
    products_without_stock.each do |product|
      puts "Initializing stock for: #{product.title}"

      # Create a stock record with 0 quantity and a reorder level of 10
      stock = product.stocks.create!(
        warehouse: default_warehouse,
        quantity: 0,
        reorder_level: 10,
      )

      # Record the stock movement
      StockMovement.record_movement(
        product,
        default_warehouse,
        0,
        "addition",
        system_user,
        "Initial stock setup (automated)"
      )

      initialized_count += 1
    end

    puts "Completed! Initialized stock records for #{initialized_count} products."
  end
end

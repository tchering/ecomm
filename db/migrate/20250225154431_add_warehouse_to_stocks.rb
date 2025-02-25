class AddWarehouseToStocks < ActiveRecord::Migration[7.1]
  def up
    # First add the column allowing nulls
    add_reference :stocks, :warehouse, null: true, foreign_key: true

    # Create a default warehouse if none exists
    default_warehouse = execute("SELECT id FROM warehouses LIMIT 1").first

    if default_warehouse.nil?
      # Create a default warehouse if none exists
      execute <<-SQL
        INSERT INTO warehouses (name, location, created_at, updated_at)
        VALUES ('Default Warehouse', 'Main Location', NOW(), NOW())
        RETURNING id
      SQL
      default_warehouse = execute("SELECT id FROM warehouses ORDER BY id DESC LIMIT 1").first
    end

    warehouse_id = default_warehouse['id']

    # Update existing records to use the default warehouse
    execute("UPDATE stocks SET warehouse_id = #{warehouse_id} WHERE warehouse_id IS NULL")

    # Now make the column non-nullable
    change_column_null :stocks, :warehouse_id, false
  end

  def down
    remove_reference :stocks, :warehouse, foreign_key: true
  end
end

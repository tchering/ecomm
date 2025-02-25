class AddReorderLevelToStocks < ActiveRecord::Migration[7.1]
  def change
    add_column :stocks, :reorder_level, :integer, default: 5, null: false
  end
end

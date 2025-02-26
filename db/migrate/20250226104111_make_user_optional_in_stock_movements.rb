class MakeUserOptionalInStockMovements < ActiveRecord::Migration[7.1]
  def change
    change_column_null :stock_movements, :user_id, true
  end
end

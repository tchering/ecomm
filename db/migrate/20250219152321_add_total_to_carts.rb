class AddTotalToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :total, :decimal
  end
end

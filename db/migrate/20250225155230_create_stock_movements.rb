class CreateStockMovements < ActiveRecord::Migration[7.1]
  def change
    create_table :stock_movements do |t|
      t.references :product, null: false, foreign_key: true
      t.references :warehouse, null: false, foreign_key: true
      t.integer :quantity
      t.string :movement_type
      t.text :notes
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

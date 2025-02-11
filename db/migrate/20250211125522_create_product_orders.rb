class CreateProductOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :product_orders do |t|
      t.references :product, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.integer :quantity
      t.string :size
      t.decimal :price, precision: 8, scale: 2

      t.timestamps
    end
  end
end

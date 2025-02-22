class AddCartReferenceToOrders < ActiveRecord::Migration[7.1]
  def change
    add_reference :orders, :cart, null: true, foreign_key: true
  end
end

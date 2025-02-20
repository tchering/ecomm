class AddCoordinatesToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :latitude, :decimal, precision: 10, scale: 6
    add_column :orders, :longitude, :decimal, precision: 10, scale: 6
  end
end

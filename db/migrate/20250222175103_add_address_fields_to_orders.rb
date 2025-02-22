class AddAddressFieldsToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :shipping_address, :string
    add_column :orders, :shipping_apartment, :string
    add_column :orders, :shipping_city, :string
    add_column :orders, :shipping_state, :string
    add_column :orders, :shipping_postal_code, :string
    add_column :orders, :shipping_country, :string
  end
end

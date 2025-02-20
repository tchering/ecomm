class AddTaxRateToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :tax_rate, :decimal, precision: 5, scale: 2
  end
end

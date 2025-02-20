class AddTaxRateToCategories < ActiveRecord::Migration[7.1]
  def change
    add_column :categories, :tax_rate, :decimal, precision: 5, scale: 2, default: 13.0
  end
end

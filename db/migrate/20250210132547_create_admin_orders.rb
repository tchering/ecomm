class CreateAdminOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.string :name
      t.string :email
      t.string :address
      t.decimal :total, precision: 8, scale: 2
      t.integer :status

      t.timestamps
    end
  end
end

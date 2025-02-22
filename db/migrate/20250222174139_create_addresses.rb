class CreateAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :addresses do |t|
      t.string :street_address
      t.string :apartment
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :country
      t.references :user, null: false, foreign_key: true
      t.boolean :is_default

      t.timestamps
    end
  end
end

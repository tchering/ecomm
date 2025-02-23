class CreateWishlistItems < ActiveRecord::Migration[7.1]
  def change
    create_table :wishlist_items do |t|
      t.references :wishlist, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end

    # Ensure a product can only be in a wishlist once
    add_index :wishlist_items, [:wishlist_id, :product_id], unique: true
  end
end

class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.integer :rating, null: false
      t.string :title
      t.text :body, null: false
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.boolean :approved, default: false
      t.integer :helpful_votes, default: 0
      t.integer :unhelpful_votes, default: 0

      t.timestamps
    end

    # Add indexes for common queries
    add_index :reviews, :rating
    add_index :reviews, :approved
    add_index :reviews, [:product_id, :approved]
    add_index :reviews, [:user_id, :product_id], unique: true
  end
end

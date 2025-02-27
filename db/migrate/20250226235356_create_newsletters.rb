class CreateNewsletters < ActiveRecord::Migration[7.1]
  def change
    create_table :newsletters do |t|
      t.string :title
      t.text :content
      t.integer :status
      t.datetime :sent_at

      t.timestamps
    end
  end
end

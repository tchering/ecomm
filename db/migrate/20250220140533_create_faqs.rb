class CreateFaqs < ActiveRecord::Migration[7.1]
  def change
    create_table :faqs do |t|
      t.string :question, null: false
      t.text :answer, null: false
      t.string :category, null: false

      t.timestamps
    end

    add_index :faqs, :question, unique: true
    add_index :faqs, :category
  end
end

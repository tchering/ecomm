class CreateContactResponses < ActiveRecord::Migration[7.1]
  def change
    create_table :contact_responses do |t|
      t.references :contact_inquiry, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :message
      t.datetime :sent_at

      t.timestamps
    end
  end
end

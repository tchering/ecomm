class CreateContactInquiries < ActiveRecord::Migration[7.1]
  def change
    create_table :contact_inquiries do |t|
      t.string :name
      t.string :email
      t.string :subject
      t.text :message
      t.integer :status
      t.datetime :resolved_at

      t.timestamps
    end
  end
end

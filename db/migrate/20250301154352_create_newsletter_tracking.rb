class CreateNewsletterTracking < ActiveRecord::Migration[7.1]
  def change
    create_table :newsletter_recipients do |t|
      t.references :newsletter, null: false, foreign_key: true
      t.references :newsletter_subscription, null: false, foreign_key: true
      t.string :status # queued, sent, failed
      t.datetime :sent_at
      t.text :error_message

      t.timestamps
    end

    create_table :newsletter_opens do |t|
      t.references :newsletter, null: false, foreign_key: true
      t.references :newsletter_subscription, null: false, foreign_key: true
      t.string :user_agent
      t.string :ip_address
      t.datetime :opened_at

      t.timestamps
    end

    create_table :newsletter_clicks do |t|
      t.references :newsletter, null: false, foreign_key: true
      t.references :newsletter_subscription, null: false, foreign_key: true
      t.string :url
      t.string :user_agent
      t.string :ip_address
      t.datetime :clicked_at

      t.timestamps
    end

    add_index :newsletter_recipients, [:newsletter_id, :newsletter_subscription_id], unique: true, name: "idx_newsletter_recipients_unique"
  end
end

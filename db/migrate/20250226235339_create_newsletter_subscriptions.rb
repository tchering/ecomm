class CreateNewsletterSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :newsletter_subscriptions do |t|
      t.string :email
      t.string :name
      t.boolean :active
      t.string :token
      t.datetime :subscribed_at
      t.datetime :unsubscribed_at

      t.timestamps
    end
    add_index :newsletter_subscriptions, :email, unique: true
    add_index :newsletter_subscriptions, :token, unique: true
  end
end

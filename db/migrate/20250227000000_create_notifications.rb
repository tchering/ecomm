class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.string :recipient_type, null: false
      t.bigint :recipient_id, null: false
      t.string :type, null: false
      t.jsonb :data
      t.datetime :read_at
      t.timestamps
    end

    add_index :notifications, [:recipient_type, :recipient_id]
  end
end

class CreateAdminCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :categories do |t|
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end

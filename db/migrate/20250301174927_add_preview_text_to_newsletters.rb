class AddPreviewTextToNewsletters < ActiveRecord::Migration[7.1]
  def change
    add_column :newsletters, :preview_text, :text
  end
end

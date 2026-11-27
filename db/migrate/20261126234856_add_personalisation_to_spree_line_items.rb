class AddPersonalisationToSpreeLineItems < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_line_items, :personalisation, :text
  end
end

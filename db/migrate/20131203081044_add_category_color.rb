class AddCategoryColor < ActiveRecord::Migration
  def change
    add_column :categories, :color, :string
    rename_column :categories, :display_name, :full_name
  end
end

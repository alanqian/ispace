class FixCategoryNameIndex < ActiveRecord::Migration
  def up
    remove_index :categories, :name
  end
  def down
    add_index :categories, :name, unique: true
  end
end

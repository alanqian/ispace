class CreateCategories < ActiveRecord::Migration
  def change
    create_table(:categories, :id => false) do |t|
      t.string :name, :length => 40, :null => false
      t.string :desc

      t.timestamps
    end
    execute "ALTER TABLE categories ADD PRIMARY KEY (name);"
  end
end

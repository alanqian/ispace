class CreateRegions < ActiveRecord::Migration
  def change
    create_table :regions, id: false do |t|
      t.string :id, :length => 80, :null => false
      t.string :name, :length => 60, :null => false
      t.string :desc

      t.timestamps

      t.index :name
    end
    execute "ALTER TABLE regions ADD PRIMARY KEY (id);"
  end
end

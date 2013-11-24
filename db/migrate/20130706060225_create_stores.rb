class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.string :region_id, :length => 80, :null => false
      t.string :name
      t.string :desc

      t.timestamps
      t.index :region_id
      t.index :name
    end
  end
end

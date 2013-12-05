class CreateFixtureItems < ActiveRecord::Migration
  def change
    create_table :fixture_items do |t|
      t.integer :fixture_id
      t.integer :bay_id
      t.integer :num_bays
      t.integer :item_index
      t.boolean :continuous

      t.timestamps

      t.index :bay_id
      t.index :fixture_id
    end
  end
end

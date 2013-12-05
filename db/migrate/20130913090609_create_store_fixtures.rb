class CreateStoreFixtures < ActiveRecord::Migration
  def up
    create_table :store_fixtures do |t|
      t.string :code, null:false
      t.integer :fixture_id, null:false
      t.integer :store_id, null:false
      t.string:category_id, null:false

      t.timestamps
      t.index [:code]
      t.index [:store_id, :code], unique:true
      t.index [:store_id, :category_id], unique:true
      t.index [:fixture_id]
    end

    remove_column :fixtures, :category_id
  end

  def down
    add_column :fixtures, :category_id, :string

    drop_table :store_fixtures
  end
end

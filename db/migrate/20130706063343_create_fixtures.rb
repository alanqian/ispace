class CreateFixtures < ActiveRecord::Migration
  def change
    create_table :fixtures do |t|
      t.string :name
      t.integer :store_id
      t.integer :user_id
      t.string :category_id
      t.decimal :run
      t.decimal :linear
      t.decimal :area
      t.decimal :cube
      t.boolean :flow_l2r

      t.timestamps
      t.index :name
      t.index :user_id
      t.index :category_id
    end
  end
end

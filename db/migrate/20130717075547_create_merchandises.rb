class CreateMerchandises < ActiveRecord::Migration
  def change
    create_table :merchandises do |t|
      t.string :product_id
      t.integer :store_id
      t.integer :user_id
      t.integer :import_id, :default => -1
      t.integer :supplier_id
      t.decimal :price
      t.boolean :new_product
      t.boolean :on_promotion
      t.boolean :force_on_shelf
      t.boolean :forbid_on_shelf
      t.integer :max_facing
      t.integer :min_facing
      t.integer :rcmd_facing
      t.integer :volume
      t.integer :vulume_rank
      t.decimal :value
      t.integer :value_rank
      t.decimal :profit
      t.integer :profit_rank
      t.decimal :psi
      t.decimal :psi_rank

      t.timestamps
      t.index :product_id
      t.index :store_id
      t.index :supplier_id
    end
  end
end

class CreateMerchandises < ActiveRecord::Migration
  def up
    create_table :merchandises do |t|
      t.string :product_id
      t.integer :store_id
      t.integer :user_id
      t.integer :import_id, default: -1
      t.decimal :price, precision: 10, scale: 2
      t.integer :facing
      t.decimal :run, precision: 10, scale: 2
      t.integer :volume
      t.integer :volume_rank
      t.decimal :value
      t.integer :value_rank
      t.float :margin
      t.integer :margin_rank
      t.decimal :psi, precision: 7, scale: 3
      t.integer :psi_rank
      t.integer :psi_by

      t.timestamps
      t.index [:store_id]
      t.index [:product_id]
      t.index [:import_id]
      t.index [:updated_at]
    end
  end

  def down
    drop_table :merchandises
  end
end

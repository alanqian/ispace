class CreateSales < ActiveRecord::Migration
  def change
    create_table :sales do |t|
      t.string :product_id, null:false
      t.integer :store_id
      t.integer :num_stores, default: 1
      t.integer :user_id
      t.integer :import_id, default: -1
      t.decimal :price, precision: 10, scale: 2
      t.integer :facing
      t.decimal :run, precision: 10, scale: 2
      t.integer :volume
      t.integer :volume_rank
      t.decimal :value
      t.integer :value_rank
      t.decimal :margin
      t.integer :margin_rank
      t.decimal :psi, precision: 7, scale: 3
      t.integer :psi_rank
      t.integer :psi_rule_id
      t.integer :rcmd_facing
      t.integer :job_id, default: -1
      t.text :detail, limit: 32 * 1024
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
  end
end

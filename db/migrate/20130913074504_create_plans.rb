class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.integer :plan_set_id, null:false
      t.string :category_id, null:false
      t.integer :user_id
      t.integer :store_id, null:false
      t.integer :num_stores, default:0
      t.integer :fixture_id, null:false
      t.integer :init_facing, default:1
      t.decimal :nominal_size,       precision: 10, scale: 2
      t.decimal :base_footage,       precision: 10, scale: 2
      t.decimal :usage_percent,      precision: 10, scale: 2
      t.datetime :published_at

      t.timestamps

      t.index [:plan_set_id]
      t.index [:category_id]
      t.index [:user_id]
      t.index [:store_id]
      t.index [:fixture_id]
      t.index [:published_at]
    end
  end
end

class CreatePlanSets < ActiveRecord::Migration
  def change
    create_table :plan_sets do |t|
      t.string :name, null:false
      t.string :notes
      t.string :category_id, null:false
      t.integer :user_id
      t.integer :plans
      t.integer :stores
      t.datetime :published_at
      t.integer :unpublished_plans
      t.integer :undeployed_stores

      t.timestamps

      t.index [:name]
      t.index [:category_id]
      t.index [:user_id]
      t.index [:created_at]
      t.index [:published_at]
      t.index [:unpublished_plans]
      t.index [:undeployed_stores]
    end
  end
end

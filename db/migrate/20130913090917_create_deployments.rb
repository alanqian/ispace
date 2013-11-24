class CreateDeployments < ActiveRecord::Migration
  def change
    create_table :deployments do |t|
      t.integer :plan_id
      t.integer :store_id
      t.integer :user_id
      t.datetime :downloaded_at
      t.datetime :deployed_at

      t.timestamps

      t.index [:store_id]
      t.index [:plan_id]
      t.index [:downloaded_at]
      t.index [:deployed_at]
    end
  end
end

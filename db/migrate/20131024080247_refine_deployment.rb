class RefineDeployment < ActiveRecord::Migration
  def up
    rename_column :deployments, :user_id, :downloaded_by

    add_column :deployments, :store_name, :string, null:false
    add_column :deployments, :plan_set_id, :integer, null:false
    add_column :deployments, :plan_set_name, :string
    add_column :deployments, :plan_set_note, :string
    add_column :deployments, :published_at, :datetime, null:false
    add_column :deployments, :to_deploy_at, :date, null:false, default:Date.today
    add_column :deployments, :download_1st_at, :datetime, default:0
    add_column :deployments, :download_count, :integer, default:0
    add_column :deployments, :deployed_by, :integer, default:0
    add_column :deployments, :discarded_by, :integer
    add_column :deployments, :discarded_at, :datetime

    add_index :deployments, :plan_set_id

    add_column :plan_sets, :to_deploy_at, :date, null:false, default:Date.today
    add_column :plan_sets, :recent_plans, :text, limit: 16777215

    rename_column :import_sheets, :_do, :done
  end

  def down
    rename_column :deployments, :downloaded_by, :user_id

    remove_column :deployments, :store_name
    remove_column :deployments, :plan_set_id
    remove_column :deployments, :plan_set_name
    remove_column :deployments, :plan_set_note
    remove_column :deployments, :published_at
    remove_column :deployments, :to_deploy_at
    remove_column :deployments, :download_1st_at
    remove_column :deployments, :download_count
    remove_column :deployments, :deployed_by
    remove_column :deployments, :discarded_by
    remove_column :deployments, :discarded_at

    remove_column :plan_sets, :to_deploy_at
    remove_column :plan_sets, :recent_plans

    rename_column :import_sheets, :done, :_do
  end
end

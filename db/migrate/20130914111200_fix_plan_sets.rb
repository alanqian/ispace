class FixPlanSets < ActiveRecord::Migration
  def up
    rename_column :plan_sets, :plans, :num_plans
    rename_column :plan_sets, :stores, :num_stores
    rename_column :plan_sets, :notes, :note
    change_column :plan_sets, :num_plans, :integer, default: 0
    change_column :plan_sets, :num_stores, :integer, default: 0

    add_index :plans, [:plan_set_id, :store_id], unique: true
    add_column :plans, :product_version, :integer, default: 0

    change_column :positions, :product_id, :string, null:false
    add_column :positions, :fixture_item_id, :integer, null:false, default: -1
    add_column :positions, :init_facing, :integer, null:false

    # add redundancy fields
    add_column :plans, :store_name, :string
    add_column :plans, :num_prior_products, :integer, default: 0
    add_column :plans, :num_normal_products, :integer, default: 0
    add_column :plans, :num_done_priors, :integer, default: 0
    add_column :plans, :num_done_normals, :integer, default: 0

    add_column :stores, :ref_count, :integer, default: 0
    add_column :stores, :region_name, :string, default: ""
    add_column :plan_sets, :category_name, :string

    add_column :categories, :pinyin, :string
    add_column :categories, :display_name, :string
    add_column :regions, :pinyin, :string
    add_column :regions, :display_name, :string
    add_column :stores, :pinyin, :string

    rename_column :products, :price_level, :price_zone
  end

  def down
    remove_column :plan_sets, :category_name
    rename_column :plan_sets, :num_plans, :plans
    rename_column :plan_sets, :num_stores, :stores
    rename_column :plan_sets, :note, :notes

    remove_index :plans, [:plan_set_id, :store_id]
    remove_column :plans, :product_version
    remove_column :plans, :store_name
    remove_column :plans, :num_prior_products
    remove_column :plans, :num_normal_products
    remove_column :plans, :num_done_priors
    remove_column :plans, :num_done_normals

    change_column :positions, :product_id, :integer
    remove_column :positions, :init_facing
    remove_column :positions, :fixture_item_id

    remove_column :stores, :ref_count
    remove_column :stores, :region_name

    remove_column :categories, :pinyin
    remove_column :categories, :display_name
    remove_column :regions, :pinyin
    remove_column :regions, :display_name
    remove_column :stores, :pinyin

    rename_column :products, :price_zone, :price_level
  end
end

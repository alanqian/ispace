class AddPlanVersion < ActiveRecord::Migration
  def change
    add_column :plans, :version, :integer, null: false, default: 0
    add_column :plans, :min_product_grade, :string, limit: 2, null: false, default: 'Q'
    add_column :positions, :version, :integer, null: false, default: 0
  end
end

class RefineFixture < ActiveRecord::Migration
  def up
    remove_column :fixtures, :store_id
    add_column :fixtures, :code, :string, limit:48, null:false, default:""
    add_index :fixtures, [:code]
  end

  def down
    remove_column :fixtures, :code
    add_column :fixtures, :store_id, :integer
  end
end

class RefineFixtureRelated < ActiveRecord::Migration
  def up
    add_column :bays, :deleted_at, :datetime
    rename_column :bays, :elem_count, :num_layers
    remove_column :bays, :elem_type
    add_column :bays, :types, :string

    add_column :fixtures, :memo, :string
    rename_column :fixtures, :delete_at, :deleted_at
    remove_column :fixtures, :code

    add_column :store_fixtures, :layers, :string
    add_column :store_fixtures, :passby, :string

    add_column :plans, :fixture_version, :integer
    add_column :plans, :layers, :string, limit: 512
  end

  def down
    remove_column :bays, :deleted_at
    rename_column :bays, :num_layers, :elem_count
    add_column :bays, :elem_type, :integer
    remove_column :bays, :types, :string

    remove_column :fixtures, :memo
    rename_column :fixtures, :deleted_at, :delete_at
    add_column :fixtures, :code, :string, limit:48, null:false, default:""
    add_index :fixtures, [:code]

    remove_column :store_fixtures, :layers
    remove_column :store_fixtures, :passby

    remove_column :plans, :fixture_version
    remove_column :plans, :layers, :string
  end
end

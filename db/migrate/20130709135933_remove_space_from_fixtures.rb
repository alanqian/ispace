class RemoveSpaceFromFixtures < ActiveRecord::Migration
  def change
    remove_column :fixtures, :run, :decimal
    remove_column :fixtures, :linear, :decimal
    remove_column :fixtures, :area, :decimal
    remove_column :fixtures, :cube, :decimal
  end
end

class AddSpaceToBays < ActiveRecord::Migration
  def change
    add_column :bays, :linear, :decimal
    add_column :bays, :area, :decimal
    add_column :bays, :cube, :decimal
  end
end

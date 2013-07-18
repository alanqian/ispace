class AddFieldsToImports < ActiveRecord::Migration
  def change
    add_column :imports, :sheets, :string
    add_column :imports, :cells, :blob
  end
end

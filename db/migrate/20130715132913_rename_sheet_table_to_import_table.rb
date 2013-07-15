class RenameSheetTableToImportTable < ActiveRecord::Migration
  def change
    rename_table :sheets, :imports
  end
end

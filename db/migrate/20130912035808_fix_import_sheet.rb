class FixImportSheet < ActiveRecord::Migration
  def up
    rename_column :import_sheets, :ob, :type
    remove_column :import_sheets, :custom
  end

  def down
    rename_column :import_sheets, :type, :ob
    add_column :import_sheets, :custom, :text, limit: 16384
  end
end

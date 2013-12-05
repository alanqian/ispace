class RefactorImportSheets < ActiveRecord::Migration
  def up
    rename_column :import_sheets, :ext, :ob
    rename_column :import_sheets, :sel_sheets, :custom
    rename_column :import_sheets, :category_id, :_do
    remove_column :import_sheets, :step
    change_column :import_sheets, :imported, :text, limit: 16384
    change_column :import_sheets, :ob, :string, limit:48
    change_column :import_sheets, :_do, :string, limit:48
    change_column :import_sheets, :custom, :text, limit: 16384

    add_index :import_sheets, [:ob]
    add_index :import_sheets, [:updated_at]

    # patch categories table
    add_column :categories, :import_id, :integer, default: -1
    add_column :regions, :import_id, :integer, default: -1
  end

  def down
    remove_index :import_sheets, [:ob]
    remove_index :import_sheets, [:updated_at]

    rename_column :import_sheets, :ob, :ext
    rename_column :import_sheets, :custom, :sel_sheets
    rename_column :import_sheets, :_do, :category_id
    add_column :import_sheets, :step, :integer

    # remove patch of categories table
    remove_column :categories, :import_id
    remove_column :regions, :import_id
  end
end

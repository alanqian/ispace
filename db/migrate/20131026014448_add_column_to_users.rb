class AddColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :username, :string
    add_column :users, :employee_id, :string
    add_column :users, :telephone, :string
  end
end

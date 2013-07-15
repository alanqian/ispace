class CreateSheets < ActiveRecord::Migration
  def change
    create_table :sheets do |t|
      t.integer :store_id
      t.integer :user_id
      t.string :comment
      t.string :filename
      t.string :ext
      t.integer :step
      t.timestamps
    end
  end
end

class DropMerchandise < ActiveRecord::Migration
  def up
    drop_table :merchandises
  end

  def down
    create_table :merchandises do |t|
      t.string :product_id, null:false
    end
  end
end

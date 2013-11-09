class AddDeleteAtToFixtures < ActiveRecord::Migration
  def change
    add_column :fixtures, :delete_at, :datetime
  end
end

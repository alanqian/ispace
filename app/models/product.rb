class Product < ActiveRecord::Base
  self.primary_key = "code"

  def self.version
    last_update_time = self.maximum(:updated_at) || 0
    last_update_time.to_i
  end

  def display_name
    "#{name} #{size_name} #{case_pack_name}"
  end

  def self.on_sales(category_id)
    self.where(["category_id=? AND sale_type <= 2", category_id])
  end
end

class Product < ActiveRecord::Base
  include RandomColor
  include UnderCategory

  scope :on_shelf, ->(grade = 'Q') { where(["grade <= ?", grade]) }

  belongs_to :category
  self.primary_key = "code"

  def self.version
    last_update_time = self.maximum(:updated_at) || 0
    last_update_time.to_i
  end

  def display_name
    "#{name} #{size_name} #{case_pack_name}"
  end

  def to_opt
    Option.new(code, display_name)
  end
end

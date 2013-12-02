class Product < ActiveRecord::Base
  include RandomColor
  include UnderCategory

  scope :can_on_shelf, -> { where("grade < 'X'") }
  scope :must_on_shelf, -> { where("grade = 'A'") }

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

  def self.on_sales(category_id)
    self.where(["category_id=? AND grade < 'X'", category_id])
  end

  # return array of options
  def self.should_on_sales(category_id)
    self.where(["category_id=? AND grade < 'X' AND grade > 'A'", category_id]).
      select(:code, :name, :size_name, :case_pack_name).map { |p| p.to_opt }
  end

  # return array of options
  def self.must_on_sales(category_id)
    self.where(["category_id=? AND grade = 'A'", category_id]).
      select(:code, :name, :size_name, :case_pack_name).map { |p| p.to_opt }
  end
end

class Supplier < ActiveRecord::Base
  belongs_to :category
  validates :category_id, :presence => true

  attr_accessor :category_name

  def category_name
    self.category.nil? ? "" : self.category.name
  end

  def self.validate_attribute(attr, value)
    mock = self.new(attr => value)
    if mock.valid?
      return nil
    else
      return mock.errors[attr]
    end
  end
end

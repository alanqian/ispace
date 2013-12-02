class Manufacturer < ActiveRecord::Base
  include RandomColor
  include UnderCategory

  belongs_to :category
  validates :category_id, :presence => true

  attr_accessor :category_name

  def self.validate_attribute(attr, value)
    mock = self.new(attr => value)
    if mock.valid?
      return nil
    else
      return mock.errors[attr]
    end
  end
end

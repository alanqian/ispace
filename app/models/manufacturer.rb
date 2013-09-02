class Manufacturer < ActiveRecord::Base
  validates :category_id, :presence => true

  def self.validate_attribute(attr, value)
    mock = self.new(attr => value)
    if mock.valid?
      return nil
    else
      return mock.errors[attr]
    end
  end
end

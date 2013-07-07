class Fixture < ActiveRecord::Base
  has_many :fixture_items, dependent: :destroy
  accepts_nested_attributes_for :fixture_items, allow_destroy: true
end

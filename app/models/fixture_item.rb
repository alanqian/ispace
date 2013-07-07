class FixtureItem < ActiveRecord::Base
  belongs_to :fixture
  belongs_to :bay
end

class Position < ActiveRecord::Base
  belongs_to :plan
  belongs_to :product

end

class Deployment < ActiveRecord::Base
  belongs_to :plan
  belongs_to :store

end

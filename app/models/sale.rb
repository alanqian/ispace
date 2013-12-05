class Sale < ActiveRecord::Base
  belongs_to :product, primary_key: :code
end

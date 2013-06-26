class OpenShelf < ActiveRecord::Base
  belongs_to :bay, :class_name => Bay

end

#encoding: utf-8
# Load the rails application.
require File.expand_path('../application', __FILE__)

# Initialize the rails application.
Ispace::Application.initialize!
Ispace::Application.configure do
  config.time_zone = 'Beijing'
  config.root = Rails.root
  config.sheet_dir = "#{Rails.root}/public/sheets/"
end

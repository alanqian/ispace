ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  # fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionController::TestCase
  include Devise::TestHelpers
end

class ActiveRecord::Base
  def to_params(excepts=[], rep_hash={})
    excepts.push "created_at", "updated_at"
    params = self.attributes
    excepts.each { |f| params.delete f }
    params.merge! rep_hash
    params
  end

  def to_new_params(excepts=["id"], rep_hash={})
    to_params(excepts, rep_hash)
  end
end

class Array
  def to_nested_params
    # open_shelves_attributes => { id => parameters_except_id }
    params = {}
    index = 0
    new_index = self.size + 100
    self.each do |r|
      if r.id
        params[index] = r.to_params
        index += 1
      else
        params[new_index] = r.to_params
        new_index += 1
      end
    end
    params
  end

  def to_new_nested_params
    params = {}
    index = self.size + 100
    self.each do |r|
      params[index] = r.to_new_params
      index += 1
    end
    params
  end
end

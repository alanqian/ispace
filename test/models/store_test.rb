require 'test_helper'

class StoreTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "should have many sales" do
    store = Store.new
    assert store.respond_to? :sales
  end
end

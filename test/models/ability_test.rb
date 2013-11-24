require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  setup do
    region = create :region
    @store = create :store, region_id: region.id
    @store2 = create :store, region_id: region.id

    @designer = create :designer
    @designer_ab = Ability.new @designer

    @admin = create :admin
    @admin_ab = Ability.new @admin

    @salesman = create :user, store: @store
    @sales_ab = Ability.new @salesman
  end

  test "should access only sale sheet" do
    assert @salesman.salesman?
    assert @salesman.store_id == @store.id
    assert @sales_ab.can? :manage, ImportSale.new(store_id: @store.id)
  end
end

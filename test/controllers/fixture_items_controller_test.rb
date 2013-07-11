require 'test_helper'

class FixtureItemsControllerTest < ActionController::TestCase
  setup do
    @fixture_item = fixture_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:fixture_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create fixture_item" do
    assert_difference('FixtureItem.count') do
      post :create, fixture_item: { bay_id: @fixture_item.bay_id, continuous: @fixture_item.continuous, fixture_id: @fixture_item.fixture_id, num_bays: @fixture_item.num_bays, row: @fixture_item.row }
    end

    assert_redirected_to fixture_item_path(assigns(:fixture_item))
  end

  test "should show fixture_item" do
    get :show, id: @fixture_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @fixture_item
    assert_response :success
  end

  test "should update fixture_item" do
    patch :update, id: @fixture_item, fixture_item: { bay_id: @fixture_item.bay_id, continuous: @fixture_item.continuous, fixture_id: @fixture_item.fixture_id, num_bays: @fixture_item.num_bays, row: @fixture_item.row }
    assert_redirected_to fixture_item_path(assigns(:fixture_item))
  end

  test "should destroy fixture_item" do
    assert_difference('FixtureItem.count', -1) do
      delete :destroy, id: @fixture_item
    end

    assert_redirected_to fixture_items_path
  end
end

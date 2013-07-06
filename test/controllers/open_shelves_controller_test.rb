require 'test_helper'

class OpenShelvesControllerTest < ActionController::TestCase
  setup do
    @open_shelf = open_shelves(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:open_shelves)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create open_shelf" do
    assert_difference('OpenShelf.count') do
      post :create, open_shelf: { bay_id: @open_shelf.bay_id, color: @open_shelf.color, depth: @open_shelf.depth, finger_space: @open_shelf.finger_space, from_back: @open_shelf.from_back, height: @open_shelf.height, level: @open_shelf.level, name: @open_shelf.name, notch_num: @open_shelf.notch_num, riser: @open_shelf.riser, slope: @open_shelf.slope, thick: @open_shelf.thick }
    end

    assert_redirected_to open_shelf_path(assigns(:open_shelf))
  end

  test "should show open_shelf" do
    get :show, id: @open_shelf
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @open_shelf
    assert_response :success
  end

  test "should update open_shelf" do
    patch :update, id: @open_shelf, open_shelf: { bay_id: @open_shelf.bay_id, color: @open_shelf.color, depth: @open_shelf.depth, finger_space: @open_shelf.finger_space, from_back: @open_shelf.from_back, height: @open_shelf.height, level: @open_shelf.level, name: @open_shelf.name, notch_num: @open_shelf.notch_num, riser: @open_shelf.riser, slope: @open_shelf.slope, thick: @open_shelf.thick }
    assert_redirected_to open_shelf_path(assigns(:open_shelf))
  end

  test "should destroy open_shelf" do
    assert_difference('OpenShelf.count', -1) do
      delete :destroy, id: @open_shelf
    end

    assert_redirected_to open_shelves_path
  end
end

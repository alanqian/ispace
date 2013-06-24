require 'test_helper'

class FreezerChestsControllerTest < ActionController::TestCase
  setup do
    @freezer_chest = freezer_chests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:freezer_chests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create freezer_chest" do
    assert_difference('FreezerChest.count') do
      post :create, freezer_chest: { bay_id: @freezer_chest.bay_id, depth: @freezer_chest.depth, height: @freezer_chest.height, inside_height: @freezer_chest.inside_height, level: @freezer_chest.level, merch_height: @freezer_chest.merch_height, name: @freezer_chest.name, wall_thick: @freezer_chest.wall_thick }
    end

    assert_redirected_to freezer_chest_path(assigns(:freezer_chest))
  end

  test "should show freezer_chest" do
    get :show, id: @freezer_chest
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @freezer_chest
    assert_response :success
  end

  test "should update freezer_chest" do
    patch :update, id: @freezer_chest, freezer_chest: { bay_id: @freezer_chest.bay_id, depth: @freezer_chest.depth, height: @freezer_chest.height, inside_height: @freezer_chest.inside_height, level: @freezer_chest.level, merch_height: @freezer_chest.merch_height, name: @freezer_chest.name, wall_thick: @freezer_chest.wall_thick }
    assert_redirected_to freezer_chest_path(assigns(:freezer_chest))
  end

  test "should destroy freezer_chest" do
    assert_difference('FreezerChest.count', -1) do
      delete :destroy, id: @freezer_chest
    end

    assert_redirected_to freezer_chests_path
  end
end

require 'test_helper'

class BaysControllerTest < ActionController::TestCase
  setup do
    @bay = bays(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bays)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create bay" do
    assert_difference('Bay.count') do
      post :create, bay: { back_color: @bay.back_color, back_height: @bay.back_height, back_thick: @bay.back_thick, back_width: @bay.back_width, base_color: @bay.base_color, base_depth: @bay.base_depth, base_height: @bay.base_height, base_width: @bay.base_width, elem_count: @bay.elem_count, elem_type: @bay.elem_type, name: @bay.name, notch_1st: @bay.notch_1st, notch_spacing: @bay.notch_spacing, takeoff_height: @bay.takeoff_height }
    end

    assert_redirected_to bay_path(assigns(:bay))
  end

  test "should show bay" do
    get :show, id: @bay
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @bay
    assert_response :success
  end

  test "should update bay" do
    patch :update, id: @bay, bay: { back_color: @bay.back_color, back_height: @bay.back_height, back_thick: @bay.back_thick, back_width: @bay.back_width, base_color: @bay.base_color, base_depth: @bay.base_depth, base_height: @bay.base_height, base_width: @bay.base_width, elem_count: @bay.elem_count, elem_type: @bay.elem_type, name: @bay.name, notch_1st: @bay.notch_1st, notch_spacing: @bay.notch_spacing, takeoff_height: @bay.takeoff_height }
    assert_redirected_to bay_path(assigns(:bay))
  end

  test "should destroy bay" do
    assert_difference('Bay.count', -1) do
      delete :destroy, id: @bay
    end

    assert_redirected_to bays_path
  end
end

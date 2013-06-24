require 'test_helper'

class RearSupportBarsControllerTest < ActionController::TestCase
  setup do
    @rear_support_bar = rear_support_bars(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rear_support_bars)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create rear_support_bar" do
    assert_difference('RearSupportBar.count') do
      post :create, rear_support_bar: { bar_depth: @rear_support_bar.bar_depth, bar_thick: @rear_support_bar.bar_thick, bay_id: @rear_support_bar.bay_id, color: @rear_support_bar.color, from_back: @rear_support_bar.from_back, height: @rear_support_bar.height, hook_length: @rear_support_bar.hook_length, level: @rear_support_bar.level, name: @rear_support_bar.name, notch_num: @rear_support_bar.notch_num }
    end

    assert_redirected_to rear_support_bar_path(assigns(:rear_support_bar))
  end

  test "should show rear_support_bar" do
    get :show, id: @rear_support_bar
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @rear_support_bar
    assert_response :success
  end

  test "should update rear_support_bar" do
    patch :update, id: @rear_support_bar, rear_support_bar: { bar_depth: @rear_support_bar.bar_depth, bar_thick: @rear_support_bar.bar_thick, bay_id: @rear_support_bar.bay_id, color: @rear_support_bar.color, from_back: @rear_support_bar.from_back, height: @rear_support_bar.height, hook_length: @rear_support_bar.hook_length, level: @rear_support_bar.level, name: @rear_support_bar.name, notch_num: @rear_support_bar.notch_num }
    assert_redirected_to rear_support_bar_path(assigns(:rear_support_bar))
  end

  test "should destroy rear_support_bar" do
    assert_difference('RearSupportBar.count', -1) do
      delete :destroy, id: @rear_support_bar
    end

    assert_redirected_to rear_support_bars_path
  end
end

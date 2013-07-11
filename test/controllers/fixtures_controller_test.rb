require 'test_helper'

class FixturesControllerTest < ActionController::TestCase
  setup do
    @fixture = fixtures(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:fixtures)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create fixture" do
    assert_difference('Fixture.count') do
      post :create, fixture: { area: @fixture.area, category_id: @fixture.category_id, cube: @fixture.cube, flow_l2r: @fixture.flow_l2r, linear: @fixture.linear, name: @fixture.name, run: @fixture.run, store_id: @fixture.store_id, user_id: @fixture.user_id }
    end

    assert_redirected_to fixture_path(assigns(:fixture))
  end

  test "should show fixture" do
    get :show, id: @fixture
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @fixture
    assert_response :success
  end

  test "should update fixture" do
    patch :update, id: @fixture, fixture: { area: @fixture.area, category_id: @fixture.category_id, cube: @fixture.cube, flow_l2r: @fixture.flow_l2r, linear: @fixture.linear, name: @fixture.name, run: @fixture.run, store_id: @fixture.store_id, user_id: @fixture.user_id }
    assert_redirected_to fixture_path(assigns(:fixture))
  end

  test "should destroy fixture" do
    assert_difference('Fixture.count', -1) do
      delete :destroy, id: @fixture
    end

    assert_redirected_to fixtures_path
  end
end

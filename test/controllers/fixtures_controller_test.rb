require 'test_helper'

class FixturesControllerTest < ActionController::TestCase
  fixtures :fixtures, :categories
  fixtures :bays

  setup do
    @logger = Rails.logger
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
      post :create, fixture: @fixture.to_new_params
    end

    assert_redirected_to Rails.application.routes.url_helpers.fixture_path(assigns(:fixture))
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
    patch :update, id: @fixture, fixture: fixtures(:two).to_new_params
    f = assigns(:fixture)
    assert_redirected_to Rails.application.routes.url_helpers.fixture_path(assigns(:fixture))
  end

  test "should destroy fixture" do
    assert_difference('Fixture.count', -1) do
      delete :destroy, id: @fixture
    end

    assert_redirected_to fixtures_path
  end
end

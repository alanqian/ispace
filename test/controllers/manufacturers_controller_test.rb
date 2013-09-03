require 'test_helper'

class ManufacturersControllerTest < ActionController::TestCase
  fixtures :manufacturers, :categories

  setup do
    @manufacturer = manufacturers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:manufacturers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create manufacturer" do
    assert_difference('Manufacturer.count') do
      params = @manufacturer.to_new_params
      params["name"] = "new_manufacturer"
      post :create, manufacturer: params
    end

    assert_redirected_to manufacturers_url(category: @manufacturer.category_id)
    # assert_redirected_to manufacturer_path(assigns(:manufacturer))
  end

  test "should show manufacturer" do
    get :show, id: @manufacturer
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @manufacturer
    assert_response :success
  end

  test "should update manufacturer" do
    patch :update, id: @manufacturer, manufacturer: { category_id: @manufacturer.category_id, color: @manufacturer.color, desc: @manufacturer.desc, name: @manufacturer.name }
    assert_redirected_to manufacturer_path(assigns(:manufacturer))
  end

  test "should destroy manufacturer" do
    assert_difference('Manufacturer.count', -1) do
      delete :destroy, id: @manufacturer
    end

    assert_redirected_to manufacturers_path
  end
end

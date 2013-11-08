require 'test_helper'

class BrandsControllerTest < ActionController::TestCase
  fixtures :categories, :brands

  setup do
    @brand = brands(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:brands)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create brand" do
    params = @brand.to_new_params
    params["name"] = "brand_new"
    assert_difference('Brand.count') do
      post :create, brand: params
    end
    # assert_redirected_to brand_path(assigns(:brand))
    assert_redirected_to brands_path(category: @brand.category_id)
  end

  test "should show brand" do
    get :show, id: @brand
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @brand
    assert_response :success
  end

  test "should update brand" do
    patch :update, id: @brand, brand: { category_id: @brand.category_id, color: @brand.color, name: @brand.name }
    assert_redirected_to brand_path(assigns(:brand))
  end

  test "should destroy brand" do
    assert_difference('Brand.count', -1) do
      delete :destroy, id: @brand
    end

    assert_redirected_to brands_path
  end
end

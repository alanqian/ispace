require 'test_helper'

class ProductsControllerTest < ActionController::TestCase
  setup do
    @product = products(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:products)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create product" do
    assert_difference('Product.count') do
      post :create, product: { bar_code: @product.bar_code, brand_id: @product.brand_id, case_pack_name: @product.case_pack_name, category_id: @product.category_id, color: @product.color, depth: @product.depth, height: @product.height, id: @product.id, mfr_id: @product.mfr_id, name: @product.name, price_level: @product.price_level, size_name: @product.size_name, user_id: @product.user_id, weight: @product.weight, width: @product.width }
    end

    assert_redirected_to product_path(assigns(:product))
  end

  test "should show product" do
    get :show, id: @product
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @product
    assert_response :success
  end

  test "should update product" do
    patch :update, id: @product, product: { bar_code: @product.bar_code, brand_id: @product.brand_id, case_pack_name: @product.case_pack_name, category_id: @product.category_id, color: @product.color, depth: @product.depth, height: @product.height, id: @product.id, mfr_id: @product.mfr_id, name: @product.name, price_level: @product.price_level, size_name: @product.size_name, user_id: @product.user_id, weight: @product.weight, width: @product.width }
    assert_redirected_to product_path(assigns(:product))
  end

  test "should destroy product" do
    assert_difference('Product.count', -1) do
      delete :destroy, id: @product
    end

    assert_redirected_to products_path
  end
end

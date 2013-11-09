require 'test_helper'

class ProductsControllerTest < ActionController::TestCase
  fixtures :products, :categories

  setup do
    @product = products(:one)
    @logger = Rails.logger
  end

  test "should redirect to sign in page if not sign in" do
    sign_out @user

    get :index
    assert_redirected_to sign_in_path

    post :create
    assert_redirected_to sign_in_path

    patch :update, id: @product.id
    assert_redirected_to sign_in_path
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
      @product = products(:new)
      @product.code = "NN00002" # MUST set with a different code
      post :create, product:
        { barcode: @product.barcode, brand_id: @product.brand_id, case_pack_name: @product.case_pack_name, category_id: @product.category_id, color: @product.color, depth: @product.depth, height: @product.height, id: @product.id, mfr_id: @product.mfr_id, name: @product.name, price_zone: @product.price_zone, size_name: @product.size_name, user_id: @product.user_id, weight: @product.weight, width: @product.width }
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
    patch :update, id: @product, product: { barcode: @product.barcode, brand_id: @product.brand_id, case_pack_name: @product.case_pack_name, category_id: @product.category_id, color: @product.color, depth: @product.depth, height: @product.height, id: @product.id, mfr_id: @product.mfr_id, name: @product.name, price_zone: @product.price_zone, size_name: @product.size_name, user_id: @product.user_id, weight: @product.weight, width: @product.width }
    assert_redirected_to product_path(assigns(:product))
  end

  test "should update product js" do
    patch :update, format: 'js', id: @product, product: { barcode: @product.barcode, brand_id: @product.brand_id, case_pack_name: @product.case_pack_name, category_id: @product.category_id, color: @product.color, depth: @product.depth, height: @product.height, id: @product.id, mfr_id: @product.mfr_id, name: @product.name, price_zone: @product.price_zone, size_name: @product.size_name, user_id: @product.user_id, weight: @product.weight, width: @product.width }
    assert_response :success
  end

  test "should destroy product" do
    assert_difference('Product.count', -1) do
      delete :destroy, id: @product
    end

    assert_redirected_to products_path
  end

  test "should update_ex product js" do
    # @logger.debug Product.all
    patch :update_ex, format: 'js',
      products: [products(:one).code, products(:two).code],
      id: @product, product: { sale_type: 0, new_product: true, on_promotion: false}
    assert_response :success
  end
end

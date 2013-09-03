require 'test_helper'

class SuppliersControllerTest < ActionController::TestCase
  fixtures :suppliers, :categories

  setup do
    @supplier = suppliers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:suppliers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create supplier" do
    assert_difference('Supplier.count') do
      post :create, supplier: {
        category_id: @supplier.category_id,
        color: @supplier.color,
        desc: @supplier.desc,
        name: "must be another name with same category id"}
    end

    # assert_redirected_to supplier_path(assigns(:supplier))
    assert_redirected_to suppliers_url(category: @supplier.category_id)
  end

  test "should show supplier" do
    get :show, id: @supplier
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @supplier
    assert_response :success
  end

  test "should update supplier" do
    patch :update, id: @supplier, supplier: { category_id: @supplier.category_id, color: @supplier.color, desc: @supplier.desc, name: @supplier.name }
    assert_redirected_to supplier_path(assigns(:supplier))
  end

  test "should destroy supplier" do
    assert_difference('Supplier.count', -1) do
      delete :destroy, id: @supplier
    end

    assert_redirected_to suppliers_path
  end
end

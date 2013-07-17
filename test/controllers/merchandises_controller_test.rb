require 'test_helper'

class MerchandisesControllerTest < ActionController::TestCase
  setup do
    @merchandise = merchandises(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:merchandises)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create merchandise" do
    assert_difference('Merchandise.count') do
      post :create, merchandise: { forbid_on_shelf: @merchandise.forbid_on_shelf, force_on_shelf: @merchandise.force_on_shelf, max_facing: @merchandise.max_facing, min_facing: @merchandise.min_facing, new_product: @merchandise.new_product, on_promotion: @merchandise.on_promotion, price: @merchandise.price, product_id: @merchandise.product_id, profit: @merchandise.profit, profit_rank: @merchandise.profit_rank, psi: @merchandise.psi, psi_rank: @merchandise.psi_rank, rcmd_facing: @merchandise.rcmd_facing, store_id: @merchandise.store_id, supplier_id: @merchandise.supplier_id, user_id: @merchandise.user_id, value: @merchandise.value, value_rank: @merchandise.value_rank, volume: @merchandise.volume, vulume_rank: @merchandise.vulume_rank }
    end

    assert_redirected_to merchandise_path(assigns(:merchandise))
  end

  test "should show merchandise" do
    get :show, id: @merchandise
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @merchandise
    assert_response :success
  end

  test "should update merchandise" do
    patch :update, id: @merchandise, merchandise: { forbid_on_shelf: @merchandise.forbid_on_shelf, force_on_shelf: @merchandise.force_on_shelf, max_facing: @merchandise.max_facing, min_facing: @merchandise.min_facing, new_product: @merchandise.new_product, on_promotion: @merchandise.on_promotion, price: @merchandise.price, product_id: @merchandise.product_id, profit: @merchandise.profit, profit_rank: @merchandise.profit_rank, psi: @merchandise.psi, psi_rank: @merchandise.psi_rank, rcmd_facing: @merchandise.rcmd_facing, store_id: @merchandise.store_id, supplier_id: @merchandise.supplier_id, user_id: @merchandise.user_id, value: @merchandise.value, value_rank: @merchandise.value_rank, volume: @merchandise.volume, vulume_rank: @merchandise.vulume_rank }
    assert_redirected_to merchandise_path(assigns(:merchandise))
  end

  test "should destroy merchandise" do
    assert_difference('Merchandise.count', -1) do
      delete :destroy, id: @merchandise
    end

    assert_redirected_to merchandises_path
  end
end

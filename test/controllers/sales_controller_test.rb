require 'test_helper'

class SalesControllerTest < ActionController::TestCase
  fixtures :sales

  setup do
    @sale = sales(:one)
  end

  test "should redirect to sign in page if not login" do
    sign_out @user

    get :index
    assert_redirected_to sign_in_path

    post :create
    assert_redirected_to sign_in_path

    patch :update, id: @sale.id
    assert_redirected_to sign_in_path
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sales)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create sale" do
    assert_difference('Sale.count') do
      post :create, sale: { detail: @sale.detail, ended_at: @sale.ended_at, facing: @sale.facing, import_id: @sale.import_id, margin: @sale.margin, margin_rank: @sale.margin_rank, num_stores: @sale.num_stores, price: @sale.price, product_id: @sale.product_id, psi: @sale.psi, psi_rank: @sale.psi_rank, psi_rule_id: @sale.psi_rule_id, rcmd_facing: @sale.rcmd_facing, run: @sale.run, started_at: @sale.started_at, store_id: @sale.store_id, user_id: @sale.user_id, value: @sale.value, value_rank: @sale.value_rank, volume: @sale.volume, volume_rank: @sale.volume_rank }
    end

    assert_redirected_to sale_path(assigns(:sale))
  end

  test "should show sale" do
    get :show, id: @sale
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @sale
    assert_response :success
  end

  test "should update sale" do
    patch :update, id: @sale, sale: { detail: @sale.detail, ended_at: @sale.ended_at, facing: @sale.facing, import_id: @sale.import_id, margin: @sale.margin, margin_rank: @sale.margin_rank, num_stores: @sale.num_stores, price: @sale.price, product_id: @sale.product_id, psi: @sale.psi, psi_rank: @sale.psi_rank, psi_rule_id: @sale.psi_rule_id, rcmd_facing: @sale.rcmd_facing, run: @sale.run, started_at: @sale.started_at, store_id: @sale.store_id, user_id: @sale.user_id, value: @sale.value, value_rank: @sale.value_rank, volume: @sale.volume, volume_rank: @sale.volume_rank }
    assert_redirected_to sale_path(assigns(:sale))
  end

  test "should destroy sale" do
    assert_difference('Sale.count', -1) do
      delete :destroy, id: @sale
    end

    assert_redirected_to sales_path
  end
end

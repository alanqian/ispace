require 'test_helper'

class MerchandisesControllerTest < ActionController::TestCase
  fixtures :merchandises

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
      post :create, merchandise: { facing: @merchandise.facing, margin: @merchandise.margin, margin_rank: @merchandise.margin_rank, price: @merchandise.price, product_id: @merchandise.product_id, psi: @merchandise.psi, psi_by: @merchandise.psi_by, psi_rank: @merchandise.psi_rank, run: @merchandise.run, store_id: @merchandise.store_id, user_id: @merchandise.user_id, value: @merchandise.value, value_rank: @merchandise.value_rank, volume: @merchandise.volume, volume_rank: @merchandise.volume_rank }
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
    patch :update, id: @merchandise, merchandise: { facing: @merchandise.facing, margin: @merchandise.margin, margin_rank: @merchandise.margin_rank, price: @merchandise.price, product_id: @merchandise.product_id, psi: @merchandise.psi, psi_by: @merchandise.psi_by, psi_rank: @merchandise.psi_rank, run: @merchandise.run, store_id: @merchandise.store_id, user_id: @merchandise.user_id, value: @merchandise.value, value_rank: @merchandise.value_rank, volume: @merchandise.volume, volume_rank: @merchandise.volume_rank }
    assert_redirected_to merchandise_path(assigns(:merchandise))
  end

  test "should destroy merchandise" do
    assert_difference('Merchandise.count', -1) do
      delete :destroy, id: @merchandise
    end

    assert_redirected_to merchandises_path
  end
end

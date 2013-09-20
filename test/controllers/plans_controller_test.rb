require 'test_helper'

class PlansControllerTest < ActionController::TestCase
  fixtures :plans

  setup do
    @plan = plans(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:plans)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create plan" do
    assert_difference('Plan.count') do
      post :create, plan: {
        category_id: @plan.category_id,
        fixture_id: @plan.fixture_id,
        init_facing: @plan.init_facing,
        plan_set_id: @plan.plan_set_id,
        store_id: @plan.store_id + 1000,
        user_id: @plan.user_id }
    end

    assert_redirected_to plan_path(assigns(:plan))
  end

  test "should show plan" do
    get :show, id: @plan
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @plan
    assert_response :success
  end

  test "should update plan" do
    patch :update, id: @plan, plan: { base_footage: @plan.base_footage, category_id: @plan.category_id, fixture_id: @plan.fixture_id, init_facing: @plan.init_facing, nominal_size: @plan.nominal_size, num_stores: @plan.num_stores, plan_set_id: @plan.plan_set_id, published_at: @plan.published_at, store_id: @plan.store_id, usage_percent: @plan.usage_percent, user_id: @plan.user_id }
    assert_redirected_to plan_path(assigns(:plan))
  end

  test "should destroy plan" do
    assert_difference('Plan.count', -1) do
      delete :destroy, id: @plan
    end

    assert_redirected_to plans_path
  end
end

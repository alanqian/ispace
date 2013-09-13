require 'test_helper'

class PlanSetsControllerTest < ActionController::TestCase
  fixtures :plan_sets

  setup do
    @plan_set = plan_sets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:plan_sets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create plan_set" do
    assert_difference('PlanSet.count') do
      post :create, plan_set: { category_id: @plan_set.category_id, name: @plan_set.name, notes: @plan_set.notes, plans: @plan_set.plans, published_at: @plan_set.published_at, stores: @plan_set.stores, undeployed_stores: @plan_set.undeployed_stores, unpublished_plans: @plan_set.unpublished_plans, user_id: @plan_set.user_id }
    end

    assert_redirected_to plan_set_path(assigns(:plan_set))
  end

  test "should show plan_set" do
    get :show, id: @plan_set
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @plan_set
    assert_response :success
  end

  test "should update plan_set" do
    patch :update, id: @plan_set, plan_set: { category_id: @plan_set.category_id, name: @plan_set.name, notes: @plan_set.notes, plans: @plan_set.plans, published_at: @plan_set.published_at, stores: @plan_set.stores, undeployed_stores: @plan_set.undeployed_stores, unpublished_plans: @plan_set.unpublished_plans, user_id: @plan_set.user_id }
    assert_redirected_to plan_set_path(assigns(:plan_set))
  end

  test "should destroy plan_set" do
    assert_difference('PlanSet.count', -1) do
      delete :destroy, id: @plan_set
    end

    assert_redirected_to plan_sets_path
  end
end

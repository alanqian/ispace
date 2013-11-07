require 'test_helper'

class PlanSetsControllerTest < ActionController::TestCase
  fixtures :categories
  fixtures :plan_sets
  fixtures :users

  setup do
    @plan_set = plan_sets(:one)
    @toothpaste = categories(:toothpaste)
    @plan_set.category_id = @toothpaste.code # patch bug of rails fixtures identify(label)
    @user = users(:one)
    sign_in @user
  end

  test "should redirect to sign in if not login" do
    sign_out @user
    get :index
    assert_redirected_to sign_in_path

    post :create
    assert_redirected_to sign_in_path
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:designing_sets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create plan_set" do
    assert_difference('PlanSet.count') do
      post :create, plan_set: {
        user_id: 1,
        category_id: @plan_set.category_id,
        name: @plan_set.name,
        note: @plan_set.note,
        user_id: @plan_set.user_id }
    end

    # redirect changed to #edit, no default
    assert_redirected_to edit_plan_set_path(assigns(:plan_set))
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
    patch :update, id: @plan_set, plan_set: {
      _do: "add_store",
      category_id: @plan_set.category_id,
      name: @plan_set.name,
      note: @plan_set.note,
      num_plans: @plan_set.num_plans,
      #published_at: @plan_set.published_at,
      #num_stores: @plan_set.num_stores,
      #undeployed_stores: @plan_set.undeployed_stores,
      #unpublished_plans: @plan_set.unpublished_plans,
      user_id: @plan_set.user_id
    }
    assert_redirected_to plan_sets_path
  end

  test "should destroy plan_set" do
    assert_difference('PlanSet.count', -1) do
      delete :destroy, id: @plan_set
    end

    assert_redirected_to plan_sets_path
  end
end

require 'test_helper'

class PlansControllerTest < ActionController::TestCase
  fixtures :categories
  fixtures :regions
  fixtures :stores
  fixtures :plans
  fixtures :plan_sets
  fixtures :fixtures
  fixtures :users

  setup do
    # modify fixtures to fit database relations
    @toothpaste = categories(:toothpaste)
    @plan_set = plan_sets(:one)
    @plan_set.category_id = @toothpaste.code # patch bug of rails fixtures identify(label)
    @plan_set.save

    store = stores(:model_store)
    store.region_id = regions(:one).code
    store.save

    @plan = plans(:one)
    @plan.plan_set_id = @plan_set.id
    @plan.store = store
    @plan.save

    @user = users(:one)
    sign_in @user

    @logger = Rails.logger
  end

  test "should get index" do
    get :index, plan_set:@plan_set.id
    assert_response :success
    assert_not_nil assigns(:plans)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  # no create interface, create plans in plan_sets, and, direct by model
  test "should create plan" do
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
    @logger.debug @plan.store_id
    @logger.debug @plan.store.to_json
    patch :update, id: @plan, plan: {
        base_footage: @plan.base_footage,
        category_id: @plan.category_id,
        fixture_id: @plan.fixture_id,
        init_facing: @plan.init_facing,
        nominal_size: @plan.nominal_size,
        plan_set_id: @plan.plan_set_id,
        usage_percent: @plan.usage_percent,
        user_id: @plan.user_id }
    #assert_redirected_to plan_path(assigns(:plan))
    assert_redirected_to plans_path(plan_set: @plan.plan_set_id)
  end

  test "should destroy plan" do
    assert_difference('Plan.count', -1) do
      delete :destroy, id: @plan
    end

    assert_redirected_to plans_path
  end

  teardown do
    sign_out @user
  end
end
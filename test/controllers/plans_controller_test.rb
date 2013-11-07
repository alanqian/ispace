require 'test_helper'

class PlansControllerTest < ActionController::TestCase
  fixtures :categories
  fixtures :regions
  fixtures :stores
  fixtures :plans
  fixtures :plan_sets

  setup do
    # modify fixtures to fit database relations
    @toothpaste = categories(:toothpaste)
    @plan = plans(:one)
    @plan_set = plan_sets(:one)
    @plan_set.category_id = @toothpaste.code # patch bug of rails fixtures identify(label)
    @plan_set.save
    store = stores(:one)
    store.region_id = regions(:one).code
    store.ref_store_id = store.id
    store.save
    @plan.store_id = store.id
    @plan.plan_set_id = @plan_set.id
    @plan.save
    @logger = Rails.logger
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
    assert_redirected_to plan_path(assigns(:plan))
  end

  test "should destroy plan" do
    assert_difference('Plan.count', -1) do
      delete :destroy, id: @plan
    end

    assert_redirected_to plans_path
  end
end

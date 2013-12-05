require 'test_helper'

class StatsControllerTest < ActionController::TestCase
  setup do
    @stat = stats(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stats)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stat" do
    assert_difference('Stat.count') do
      post :create, stat: { agg_id: @stat.agg_id, category_id: @stat.category_id, job_id: @stat.job_id, name: @stat.name, num_facings: @stat.num_facings, num_positions: @stat.num_positions, outcome: @stat.outcome, percentage: @stat.percentage, plan_set_id: @stat.plan_set_id, rel_model: @stat.rel_model, run: @stat.run, stat_type: @stat.stat_type }
    end

    assert_redirected_to stat_path(assigns(:stat))
  end

  test "should show stat" do
    get :show, id: @stat
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @stat
    assert_response :success
  end

  test "should update stat" do
    patch :update, id: @stat, stat: { agg_id: @stat.agg_id, category_id: @stat.category_id, job_id: @stat.job_id, name: @stat.name, num_facings: @stat.num_facings, num_positions: @stat.num_positions, outcome: @stat.outcome, percentage: @stat.percentage, plan_set_id: @stat.plan_set_id, rel_model: @stat.rel_model, run: @stat.run, stat_type: @stat.stat_type }
    assert_redirected_to stat_path(assigns(:stat))
  end

  test "should destroy stat" do
    assert_difference('Stat.count', -1) do
      delete :destroy, id: @stat
    end

    assert_redirected_to stats_path
  end
end

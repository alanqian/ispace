=begin "interfaces of :plan_sets"

features:

#index: PlanSet: List recent plan_sets
  for Designer:
  1. Plans on designing, by created_at
     * designing plan_sets, filter: category
     * quick launch for each plan_sets: last edited plans
       Plan.recent_edited
  2. published/undeployed plan_sets:
     * model store, notes, published date;
     * deployed stores, w/ download/deploy date
     * undeployed stores
     * recent download store w/ date...
     * recent deployed store w/ date...
  3. deployed plan_sets
     * published date, download date range, deploy date range

  for Store: order by published date;
  1. recent plans
     plan_name, download link, published date, download date; link_to :report
  2. deployed plans, ordered by
     plan_name, download link, published date, download_date, deployed date

#new: new PlanSet

#show: TBD:
  1. show planset summary, published?,
  2. show Plans in PlanSet;
  3. for published PlanSet, show downloaded? deployed?
  name: name+category+date(stores)

#edit:
  1. for unpublished, edit summary
     if plans exists, cannot change category!
  2. for undownloaded, publish/unpublish plans in PlanSet

#update:
  1. add/remove plan
  2. update summary

#destroy:
  Can drop only if it is empty

plans:

#index: no use

#new: new Plan

#show:
  anchor text: store_name(num_stores);

#edit:
  1. edit summary
  2. edit product layout
  3. edit publish

#update: _do=publish,unpublish,nil
  1. summary
  2. layout
  3. publish state, by ajax?

=end

class PlanSetsController < ApplicationController
  before_action :set_commons
  before_action :set_options, only: [:index, :new, :show, :edit, :create, :update]
  before_action :set_plan_set, only: [:show, :edit, :update, :destroy]

  # GET /plan_sets
  # GET /plan_sets.json
  def index
    @role = :designer
    case @role
    when :designer
      # for designers
      @designing_sets = PlanSet.designing_sets
      @recent_plans = Plan.recent_edited
      @deploying_sets = PlanSet.deploying_sets
      @deployed_sets = PlanSet.deployed_sets(10)
    when :store
      # for stores
      @store_id = 9
      @recent_plans = Deployment.recent_plans(@store_id)
      @deployed_plans = Deployment.deployed_plans(@store_id, 100)
      render 'index_store'
    end
  end

  # GET /plan_sets/1
  # GET /plan_sets/1.json
  def show
  end

  # GET /plan_sets/new
  def new
    @plan_set = new_plan_set
    @categories_all = Category.all
  end

  # GET /plan_sets/1/edit
  # @do: publish
  # @do: nil # add_store
  def edit
    @off = params[:off] || "0"
  end

  # POST /plan_sets
  # POST /plan_sets.json
  def create
    @plan_set = PlanSet.new(plan_set_params)
    respond_to do |format|
      if @plan_set.save
        format.html {
          redirect_to edit_plan_set_path(@plan_set, _do: :add_store), notice: 'Plan set was successfully created.'
        }
        format.json { render action: 'show', status: :created, location: @plan_set }
      else
        format.html { render action: 'new' }
        format.json { render json: @plan_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /plan_sets/1
  # PATCH/PUT /plan_sets/1.json
  # _do: :publish, off: 0/1
  def update_publish
    publish_off = params[:plan_set][:off] || "0"
    respond_to do |format|
      if @commit == :cancel || @commit == :back
        format.html { redirect_to plan_sets_path }
        format.json { head :no_content }
      elsif @plan_set.publish(publish_off.to_i == 0, @user_id)
        format.html { redirect_to plan_sets_path, notice: 'Plan set was successfully published.' }
        format.json { head :no_content }
      else
        format.html { redirect_to plan_sets_path, notice: 'Plan set was not published.' }
        format.json { render json: @plan_set.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_add_store
    respond_to do |format|
      if @commit == :cancel || @commit == :back
        format.html { redirect_to plan_sets_path, notice: nil }
        format.json { head :no_content }
      elsif @plan_set.update(plan_set_params)
        format.html { redirect_to plan_sets_path, notice: 'Plan set was successfully updated.' }
        format.json { head :no_content }
        format.js { set_plan_set_update_js }
      else
        format.html { redirect_to plan_sets_path, notice: 'Plan set was not updated.' }
        format.json { render json: @plan_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plan_sets/1
  # DELETE /plan_sets/1.json
  def destroy
    @plan_set.destroy
    respond_to do |format|
      format.html { redirect_to plan_sets_url }
      format.json { head :no_content }
    end
  end

  private
    def set_commons
      @store_id = 1
      @user_id = 1
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_plan_set
      @plan_set = PlanSet.find(params[:id])
      @plan_set._do = @do
    end

    def new_plan_set
      @plan_set = PlanSet.new({user_id: @user_id})
    end

    def set_options
      @categories_all = Category.select([:code, :name, :pinyin, :parent_id]).order(:code)
      @category_map = {}.tap { |h| @categories_all.each { |c| h[c.code] = c.name } }
      @model_stores_all = Store.model_stores
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def plan_set_params
      params.require(:plan_set).permit(:_do, :name, :note, :category_id, :category_name, :to_deploy_at, :user_id, model_stores:[] )
    end

    def set_fixture_update_js
      @plan_set.reload
    end
end

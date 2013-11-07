=begin "interfaces of :plan_sets"

features:

#index: PlanSet: List recent plan_sets

#new: new PlanSet

#show: TBD:
  1. show planset summary, published?,
  2. show Plans in PlanSet;
  3. for published PlanSet, show downloaded? deployed?
  name: name+category+date(stores)

#edit:
  1. for unpublished, edit summary
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
    @plan_sets = PlanSet.all
    render "index", locals: { plan_set_new: PlanSet.new }
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
  def edit
    @do = :default
  end

  # POST /plan_sets
  # POST /plan_sets.json
  def create
    @plan_set = PlanSet.new(plan_set_params)

    respond_to do |format|
      if @plan_set.save
        format.html {
          @do = :edit_add_store
          redirect_to edit_plan_set_path(@plan_set), notice: 'Plan set was successfully created.'
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
  def update
    respond_to do |format|
      if @plan_set.update(plan_set_params)
        format.html { redirect_to @plan_set, notice: 'Plan set was successfully updated.' }
        format.json { head :no_content }
        format.js { set_plan_set_update_js }
      else
        format.html { render action: 'edit' }
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
      params.require(:plan_set).permit(:name, :note, :category_id, :user_id, model_stores:[] )
    end

    def set_fixture_update_js
      @plan_set.reload
    end
end

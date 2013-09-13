class PlanSetsController < ApplicationController
  before_action :set_plan_set, only: [:show, :edit, :update, :destroy]

  # GET /plan_sets
  # GET /plan_sets.json
  def index
    @plan_sets = PlanSet.all
  end

  # GET /plan_sets/1
  # GET /plan_sets/1.json
  def show
  end

  # GET /plan_sets/new
  def new
    @plan_set = PlanSet.new
  end

  # GET /plan_sets/1/edit
  def edit
  end

  # POST /plan_sets
  # POST /plan_sets.json
  def create
    @plan_set = PlanSet.new(plan_set_params)

    respond_to do |format|
      if @plan_set.save
        format.html { redirect_to @plan_set, notice: 'Plan set was successfully created.' }
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
    # Use callbacks to share common setup or constraints between actions.
    def set_plan_set
      @plan_set = PlanSet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def plan_set_params
      params.require(:plan_set).permit(:name, :notes, :category_id, :user_id, :plans, :stores, :published_at, :unpublished_plans, :undeployed_stores)
    end
end

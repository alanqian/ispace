class PlansController < ApplicationController
  before_action :set_commons
  before_action :set_options, only: [:new, :show, :edit, :update ]
  before_action :set_plan, only: [:show, :edit, :update, :destroy]

  # GET /plans
  # GET /plans.json
  def index
    @plans = Plan.all
  end

  # GET /plans/1
  # GET /plans/1.json
  def show
  end

  # GET /plans/new
  def new
    @plan = new_plan
  end

  # GET /plans/1/edit
  # product layout editor, include view elements
  # 1. edit summary, in a dialog
  # 2. can switch to other category
  # 3. product#index, show products on shelf
  # 4. product#edit, edit products summary
  # 5. position edit, by jquery sort
  def edit
    # check store_fixtures: store + category
    # _do: :edit_layout, :edit_setup, :edit_summay(:edit)
    if params[:_do]
      # :edit_summary here
      @do = "edit_#{params[:_do]}".downcase.to_sym
    else
      @do = :edit
    end

    # check positions, if none, initialize; (online tools: #reinitialize position)
    # show layout editor, product index list, tool buttons
    # always ajax requests in :edit_layout mode
    if @do == :edit_layout
      @missing_fixture = !@plan.verify_fixture?
      @do = :edit_setup if (@missing_fixture)

      if @plan.products_changed?
        @optional_products = @plan.optional_products
        @do = :edit_setup if @optional_products.any?
      end
    end

    if @do == :edit_setup
      @fixtures_all = Fixture.select([:id,:name]).to_hash(:id, :name)
      @optional_products ||= @plan.optional_products
    end

    render @do;
  end

  # POST /plans
  # POST /plans.json
  def create
  end

  # PATCH/PUT /plans/1
  # PATCH/PUT /plans/1.json
  # _do: setup, layout, edit(summary)
  def update
    @do = (params[:_do] || "edit").to_sym
    logger.debug "plans#update, _do:#{@do}"

    respond_to do |format|
      if @plan.update(plan_params)
        format.html {
          if @do == :setup
            redirect_to edit_plan_path(@plan, _do: "layout")
          else
            redirect_to @plan, notice: 'Plan was successfully updated.'
          end
        }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plans/1
  # DELETE /plans/1.json
  def destroy
    @plan.destroy
    respond_to do |format|
      format.html { redirect_to plans_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_commons
      @user_id = 1
      @store_id = 1
    end

    def set_plan
      @plan = Plan.find(params[:id])
    end

    def new_plan
      plan_set_id = params[:plan_set]
      category_id = params[:cat]
      @plan = Plan.new({
        user_id: @user_id,
        plan_set_id: plan_set_id,
        category_id: category_id
      })
    end

    def set_options
      @model_stores_all = Store.model_store_options
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def plan_params
      params.require(:plan).permit(:plan_set_id, :category_id, :user_id, :fixture_id,
        :init_facing, :nominal_size, :base_footage, :usage_percent, :published_at,
        optional_products:[])
    end
end

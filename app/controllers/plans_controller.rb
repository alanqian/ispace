class PlansController < ApplicationController
  before_action :set_commons
  before_action :set_options, only: [:new, :show, :edit, :update ]
  before_action :set_plan, only: [:show, :edit, :update, :destroy]

  # GET /plans
  # GET /plans.json
  def index
    plan_set = PlanSet.find(params[:plan_set])
    @plans = Plan.where(plan_set_id: plan_set.id)
    store_id_list = @plans.map { |plan| plan.store_id }
    store_map = Store.follow_store_map(store_id_list)
    render "index", locals: { plan_set: plan_set, store_map: store_map }
  end

  # GET /plans/1
  # GET /plans/1.json
  def show
    if @do == :download_pdf
      logger.debug "start download_pdf, plan:#{@plan.id}"
      download_pdf
    else
      # default
    end
  end

  def download_pdf
    @store_id = 9
    @user_id = 100
    path = @plan.plan_pdf
    deploy = Deployment.start_download(@plan.id, @store_id)
    if File.exists?(path) && deploy != nil
      send_file(path, x_sendfile: true, filename: "#{deploy.plan_set_name}-#{@store_id}.#{@user_id}.pdf")
      deploy.download(@user_id)
      logger.info "download plan, plan:#{@plan.id} store:#{@store_id} user:#{@user_id}"
    else
      raise ActionController::RoutingError, "resource not found"
    end
  end

  # GET /plans/new
  # nothing
  def new
    @plan = new_plan
  end

  # POST /plans
  # POST /plans.json
  # nothing
  def create
  end


  # GET /plans/1/edit
  # product layout editor, include view elements
  # 1. edit summary, in a dialog
  # 2. can switch to other category
  # 3. product#index, show products on shelf
  # 4. product#edit, edit products summary
  # 5. position edit, by jquery sortable
  def edit
    # check store_fixtures: store + category
    # _do: :layout, :setup, nil

    # check positions, if none, initialize; (online tools: #reinitialize position)
    # show layout editor, product index list, tool buttons
    # always ajax requests in :edit_layout mode
    if @do == :layout
      @missing_fixture = !@plan.verify_fixture?
      @do = :setup if (@missing_fixture)

      if @plan.products_changed?
        @do = :setup
      end
    end

    logger.debug "edit plan, do:#{@do}"
    case @do
    when :setup
      @fixtures_all = Fixture.select([:id,:name]).to_hash(:id, :name)
      @products_opt = @plan.products_opt
      render "edit_setup"
    when :layout
      @position = Position.new
      render "edit_layout", locals: {
        products: Product.on_sales(@plan.category_id),
        brands_all: Brand.where(["category_id=?", @plan.category_id]),
        suppliers_all: Supplier.where(["category_id=?", @plan.category_id]),
        mfrs_all: Manufacturer.where(["category_id=?", @plan.category_id]),
      }
    else
      render "edit"
    end
  end

  def update_deploy
    @store_id = 9
    @user_id = 100
    deploy = Deployment.find(params[:deployed])
    if deploy && deploy.store_id == @store_id && deploy.plan_id == @plan.id
      deploy.deploy(@user_id)
      logger.info "plan deployed: plan:#{@plan.id} store:#{@store_id} deploy:#{deploy.id}"
    end
    redirect_to plan_sets_path
  end

  # set basic plan info, init_facing only in current version
  def update_default
    respond_to do |format|
      if @plan.update(plan_params)
        format.html {
          redirect_to plans_path(plan_set: @plan.plan_set_id)
        }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_setup
    respond_to do |format|
      if @plan.update(plan_params)
        format.html {
          redirect_to edit_plan_path(@plan, _do: "layout")
        }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # ajax call
  # :layout, :copy_to, :position, :summary
  def update_others
    respond_to do |format|
      if @plan.update(plan_params)
        format.html {
          redirect_to @plan, notice: 'Plan was successfully updated.'
        }
        format.json { head :no_content }
        format.js {
          @version = params[:_version]
          render "update_#{@do}"
        }
      else
        format.html { render action: 'edit', _do: "layout" }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
        format.js {
          @version = params[:_version]
          render "update_#{@do}"
        }
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
      @plan._do = @do
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
      params.require(:plan).permit(:plan_set_id, :category_id, :_do, :user_id, :fixture_id,
        :init_facing, :nominal_size, :base_footage, :usage_percent,
        :copy_product_only,
        target_plans:[],
        optional_products:[],
        positions_attributes: [:_destroy, :id,
          :product_id, :fixture_item_id, :layer, :seq_num, :init_facing, :facing,
          :run, :units, :height_units, :width_units, :depth_units, :oritentation,
          :merch_style, :peg_style,
          :top_cap_height, :top_cap_depth, :bottom_cap_height, :bottom_cap_depth,
          :left_cap_width, :left_cap_depth, :right_cap_width, :right_cap_depth,
          :leading_gap, :leading_divider, :middle_divider, :trail_divider,]
        )
    end
end

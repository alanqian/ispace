class FixturesController < ApplicationController
  before_action :set_fixture, only: [:show, :edit, :update, :destroy]
  before_action :set_aux, only: [:new, :edit]

  # GET /fixtures
  # GET /fixtures.json
  def index
    @fixtures = Fixture.all
    render "index", locals: { fixture_new: Fixture.new }
  end

  # GET /fixtures/1
  # GET /fixtures/1.json
  def show
  end

  # GET /fixtures/new
  def new
    @fixture = Fixture.new
    @fixture_item_new = FixtureItem.new(
      num_bays: 1,
      item_index: -1,
      continuous: true)
  end

  # GET /fixtures/1/edit
  def edit
    @fixture_item_new = FixtureItem.new(
      fixture_id: @fixture.id,
      num_bays: 1,
      item_index: -1,
      continuous: true)
  end

  # POST /fixtures
  # POST /fixtures.json
  def create
    @fixture = Fixture.new(fixture_params)
    @fixture.user_id = current_user.id

    respond_to do |format|
      if @fixture.save
        format.html { redirect_to @fixture, notice: 'Fixture was successfully created.' }
        format.json { render action: 'show', status: :created, location: @fixture }
      else
        format.html { render action: 'new' }
        format.json { render json: @fixture.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fixtures/1
  # PATCH/PUT /fixtures/1.json
  def update
    respond_to do |format|
      if @fixture.update(fixture_params)
        logger.debug fixture_params
        format.html { redirect_to @fixture, notice: 'Fixture was successfully updated.' }
        format.json { head :no_content }
        format.js { set_fixture_update_js }
      else
        format.html { render action: 'edit' }
        format.json { render json: @fixture.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fixtures/1
  # DELETE /fixtures/1.json
  def destroy
    @fixture.delete_at = Time.now
    @fixture.save
    respond_to do |format|
      format.html { redirect_to fixtures_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fixture
      @fixture = Fixture.find(params[:id])
    end

    def set_aux
      # load categories
      @categories = Category.select("name").map { |ar| ar.name }

      # load all bays: id => name, run, liear, area, cube
      @bays = Bay.all
      space = @bays.map { |bay| [bay.id, { name: bay.name, run: bay.run,
        linear: bay.linear, area: bay.area, cube: bay.cube}] }
      @space = Hash[space]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fixture_params
      params.require(:fixture).permit(
        :name, :code, :user_id, :category_id,
        :flow_l2r,
        fixture_items_attributes: [:_destroy, :id, :bay_id, :num_bays, :continuous])
    end

    def set_fixture_update_js
      @fixture.reload
    end
end

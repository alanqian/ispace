class FixtureItemsController < ApplicationController
  before_action :set_fixture_item, only: [:show, :edit, :update, :destroy]

  # GET /fixture_items
  # GET /fixture_items.json
  def index
    @fixture_items = FixtureItem.all
  end

  # GET /fixture_items/1
  # GET /fixture_items/1.json
  def show
  end

  # GET /fixture_items/new
  def new
    @fixture_item = FixtureItem.new
  end

  # GET /fixture_items/1/edit
  def edit
  end

  # POST /fixture_items
  # POST /fixture_items.json
  def create
    @fixture_item = FixtureItem.new(fixture_item_params)

    respond_to do |format|
      if @fixture_item.save
        format.html { redirect_to @fixture_item, notice: 'Fixture item was successfully created.' }
        format.json { render action: 'show', status: :created, location: @fixture_item }
      else
        format.html { render action: 'new' }
        format.json { render json: @fixture_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fixture_items/1
  # PATCH/PUT /fixture_items/1.json
  def update
    respond_to do |format|
      if @fixture_item.update(fixture_item_params)
        format.html { redirect_to @fixture_item, notice: 'Fixture item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @fixture_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fixture_items/1
  # DELETE /fixture_items/1.json
  def destroy
    @fixture_item.destroy
    respond_to do |format|
      format.html { redirect_to fixture_items_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fixture_item
      @fixture_item = FixtureItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fixture_item_params
      params.require(:fixture_item).permit(:fixture_id, :bay_id, :num_bays, :row, :continuous)
    end
end

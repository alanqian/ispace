class FreezerChestsController < ApplicationController
  before_action :set_freezer_chest, only: [:show, :edit, :update, :destroy]

  # GET /freezer_chests
  # GET /freezer_chests.json
  def index
    @freezer_chests = FreezerChest.all
  end

  # GET /freezer_chests/1
  # GET /freezer_chests/1.json
  def show
  end

  # GET /freezer_chests/new
  def new
    @freezer_chest = FreezerChest.new
  end

  # GET /freezer_chests/1/edit
  def edit
  end

  # POST /freezer_chests
  # POST /freezer_chests.json
  def create
    @freezer_chest = FreezerChest.new(freezer_chest_params)

    respond_to do |format|
      if @freezer_chest.save
        format.html { redirect_to @freezer_chest, notice: 'Freezer chest was successfully created.' }
        format.json { render action: 'show', status: :created, location: @freezer_chest }
      else
        format.html { render action: 'new' }
        format.json { render json: @freezer_chest.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /freezer_chests/1
  # PATCH/PUT /freezer_chests/1.json
  def update
    respond_to do |format|
      if @freezer_chest.update(freezer_chest_params)
        format.html { redirect_to @freezer_chest, notice: 'Freezer chest was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @freezer_chest.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /freezer_chests/1
  # DELETE /freezer_chests/1.json
  def destroy
    @freezer_chest.destroy
    respond_to do |format|
      format.html { redirect_to freezer_chests_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_freezer_chest
      @freezer_chest = FreezerChest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def freezer_chest_params
      params.require(:freezer_chest).permit(:bay_id, :level, :name, :height, :depth, :inside_height, :wall_thick, :merch_height)
    end
end

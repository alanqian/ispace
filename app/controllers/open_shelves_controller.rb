class OpenShelvesController < ApplicationController
  before_action :set_open_shelf, only: [:show, :edit, :update, :destroy]

  # GET /open_shelves
  # GET /open_shelves.json
  def index
    @open_shelves = OpenShelf.all
  end

  # GET /open_shelves/1
  # GET /open_shelves/1.json
  def show
  end

  # GET /open_shelves/new
  def new
    @open_shelf = OpenShelf.new
  end

  # GET /open_shelves/1/edit
  def edit
  end

  # POST /open_shelves
  # POST /open_shelves.json
  def create
    @open_shelf = OpenShelf.new(open_shelf_params)

    respond_to do |format|
      if @open_shelf.save
        format.html { redirect_to @open_shelf, notice: 'Open shelf was successfully created.' }
        format.json { render action: 'show', status: :created, location: @open_shelf }
      else
        format.html { render action: 'new' }
        format.json { render json: @open_shelf.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /open_shelves/1
  # PATCH/PUT /open_shelves/1.json
  def update
    respond_to do |format|
      if @open_shelf.update(open_shelf_params)
        format.html { redirect_to @open_shelf, notice: 'Open shelf was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @open_shelf.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /open_shelves/1
  # DELETE /open_shelves/1.json
  def destroy
    @open_shelf.destroy
    respond_to do |format|
      format.html { redirect_to open_shelves_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_open_shelf
      @open_shelf = OpenShelf.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def open_shelf_params
      params.require(:open_shelf).permit(:bay_id, :level, :name, :height, :depth, :thick, :slope, :riser, :notch_num, :color, :from_back, :finger_space)
    end
end

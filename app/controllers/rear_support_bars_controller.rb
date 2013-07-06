class RearSupportBarsController < ApplicationController
  before_action :set_rear_support_bar, only: [:show, :edit, :update, :destroy]

  # GET /rear_support_bars
  # GET /rear_support_bars.json
  def index
    @rear_support_bars = RearSupportBar.all
  end

  # GET /rear_support_bars/1
  # GET /rear_support_bars/1.json
  def show
  end

  # GET /rear_support_bars/new
  def new
    @rear_support_bar = RearSupportBar.new
  end

  # GET /rear_support_bars/1/edit
  def edit
  end

  # POST /rear_support_bars
  # POST /rear_support_bars.json
  def create
    @rear_support_bar = RearSupportBar.new(rear_support_bar_params)

    respond_to do |format|
      if @rear_support_bar.save
        format.html { redirect_to @rear_support_bar, notice: 'Rear support bar was successfully created.' }
        format.json { render action: 'show', status: :created, location: @rear_support_bar }
      else
        format.html { render action: 'new' }
        format.json { render json: @rear_support_bar.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rear_support_bars/1
  # PATCH/PUT /rear_support_bars/1.json
  def update
    respond_to do |format|
      if @rear_support_bar.update(rear_support_bar_params)
        format.html { redirect_to @rear_support_bar, notice: 'Rear support bar was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @rear_support_bar.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rear_support_bars/1
  # DELETE /rear_support_bars/1.json
  def destroy
    @rear_support_bar.destroy
    respond_to do |format|
      format.html { redirect_to rear_support_bars_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rear_support_bar
      @rear_support_bar = RearSupportBar.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rear_support_bar_params
      params.require(:rear_support_bar).permit(:bay_id, :level, :name, :height, :bar_depth, :bar_thick, :from_back, :hook_length, :notch_num, :color)
    end
end

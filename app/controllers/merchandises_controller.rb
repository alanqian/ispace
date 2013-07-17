class MerchandisesController < ApplicationController
  before_action :set_merchandise, only: [:show, :edit, :update, :destroy]

  # GET /merchandises
  # GET /merchandises.json
  def index
    @merchandises = Merchandise.all
  end

  # GET /merchandises/1
  # GET /merchandises/1.json
  def show
  end

  # GET /merchandises/new
  def new
    @merchandise = Merchandise.new
  end

  # GET /merchandises/1/edit
  def edit
  end

  # POST /merchandises
  # POST /merchandises.json
  def create
    @merchandise = Merchandise.new(merchandise_params)

    respond_to do |format|
      if @merchandise.save
        format.html { redirect_to @merchandise, notice: 'Merchandise was successfully created.' }
        format.json { render action: 'show', status: :created, location: @merchandise }
      else
        format.html { render action: 'new' }
        format.json { render json: @merchandise.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /merchandises/1
  # PATCH/PUT /merchandises/1.json
  def update
    respond_to do |format|
      if @merchandise.update(merchandise_params)
        format.html { redirect_to @merchandise, notice: 'Merchandise was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @merchandise.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /merchandises/1
  # DELETE /merchandises/1.json
  def destroy
    @merchandise.destroy
    respond_to do |format|
      format.html { redirect_to merchandises_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_merchandise
      @merchandise = Merchandise.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def merchandise_params
      params.require(:merchandise).permit(:product_id, :store_id, :user_id, :supplier_id, :price, :new_product, :on_promotion, :force_on_shelf, :forbid_on_shelf, :max_facing, :min_facing, :rcmd_facing, :volume, :vulume_rank, :value, :value_rank, :profit, :profit_rank, :psi, :psi_rank)
    end
end

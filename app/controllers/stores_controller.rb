class StoresController < ApplicationController
  before_action :set_store, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /stores
  # GET /stores.json
  def index
    @regions = Region.all
    case @current_user_role
    when :admin
      @stores = Store.all
      render "index", locals: { store_new: Store.new }
    when :designer
      if @do == :activity
        render "index_activity"
      else
        @model_stores = Store.model_stores
        @stores = Store.all.order(:ref_store_id, ref_count: :desc)
        render "index_designer", locals: { store_new: Store.new }
      end
    end
  end

  # GET /stores/1
  # GET /stores/1.json
  def show
  end

  # GET /stores/new
  def new
    @store = Store.new
  end

  # GET /stores/1/edit
  def edit
  end

  # POST /stores
  # POST /stores.json
  def create
    @store = Store.new(store_params)
    respond_to do |format|
      if @store.save
        format.html { redirect_to @store, notice: simple_notice }
        format.json { render action: 'show', status: :created, location: @store }
      else
        format.html { render action: 'new' }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_model_store
    @commit ||= :set_model_store # js call no commit parameter
    logger.debug "stores: #{params[:stores]}"
    logger.debug "commit: #{@commit}"
    respond_to do |format|
      if Store.setup_model_store(@commit, params[:stores], params[:store][:ref_store_id])
        format.html { redirect_to stores_path,
          notice: simple_notice(message: :update_model_store) }
      else
        format.html { redirect_to stores_path,
          notice: simple_notice(message: :update_model_store_fail) }
      end
    end
  end

  # PATCH/PUT /stores/1
  # PATCH/PUT /stores/1.json
  def update_default
    respond_to do |format|
      if @store.update(store_params)
        format.html { redirect_to @store, notice: simple_notice }
        format.json { head :no_content }
        format.js { set_store_update_js }
      else
        format.html { render action: 'edit' }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stores/1
  # DELETE /stores/1.json
  def destroy
    @store.destroy
    respond_to do |format|
      format.html { redirect_to stores_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_store
      @store = Store.find(params[:id]) if params[:id]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def store_params
      params.require(:store).permit(:_do, :region_id, :code, :name, :ref_store_id, :area, :location, :memo)
    end

    def set_store_update_js
      @store.reload
      @regions = Region.all
    end
end

=begin "interfaces of :import_sheet"

features:
a. import_stores
b. import_categories
c. import_products
d. import_sales

I. import list: #index, (for products, sales only)

II. steps for import: (for all imports)

1. upload xls file: #new -> #create
   -> ok: redirect to #edit: show import results + preview, -> import or cancel
      fail: redirect to #new with with preview & errors, -> upload again

2. #edit: import data with preview, -> #update
   -> ok: show results, #show
      fail: redirect to #edit: show results and errors

3. #show: show import results, with discard button, display links

III. discard import: #destroy, (for all imports)

=end

class ImportSheetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_import_sheet, only: [:show, :edit, :update, :destroy]
  # respond_to :json

  # GET /import_sheets
  # GET /import_sheets.json
  # -----------------------------------------
  # 0. generic index, for test only
  # 1. import product list, all
  # 2. import sale list,
  #    :all for design, :this store for sales
  def index
    store_id = 1
    user_id = 1
    is_designer_user = params[:_designer]

    @t = params[:_t] || "sale"
    case @t
    when "sale"
      # show import sales list
      if is_designer_user
        # all recent imports
        @import_sheets = ImportSale.where(done: 'import').order(created_at: :desc)
        render 'index.sales_d'
      else
        # imports of his own store
        @import_sheets = ImportSale.where([
          "done='import' and store_id=?", store_id]).order(created_at: :desc)
        render 'index.sales'
      end
    when "product"
      # all recent imported products
      @import_sheets = ImportProduct.order(created_at: :desc)
      render 'index.products'
    else
      # show generic #index page, for debug only
      @import_sheets = ImportSheet.order(created_at: :desc)
      render 'index'
    end
  end

  # GET /import_sheets/1
  # GET /import_sheets/1.json
  # -----------------------------------------
  # show import results: for all imports
  def show
  end

  # GET /import_sheets/new?_t=xxx
  # -----------------------------------------
  # launch upload page: for all imports
  def new
    @store_id = 1

    @import_sheet = new_import_sheet
    respond_to do |format|
      if params[:ajax]
        format.html { render partial: 'upload', locals: { import_sheet: @import_sheet }}
      else
        format.html
      end
    end
  end

  # GET /import_sheets/1/edit
  # -----------------------------------------
  # show upload result, then select to import or upload again: for all imports
  # for all imports
  def edit
  end

  # POST /import_sheets
  # POST /import_sheets.json
  # -----------------------------------------
  # create: import:upload, goto #edit if success, #new otherwise
  # for all imports
  def create
    @import_sheet = ImportSheet.new(import_sheet_params)

    respond_to do |format|
      if @import_sheet.save
        format.html {
          logger.debug "upload ok"
          redirect_to edit_import_sheet_path(@import_sheet),
            notice: 'spreadsheet was successfully uploaded.'
        }
        format.json { render action: 'show', status: :created, location: @import_sheet }
        format.js
      else
        logger.warn "upload failed, id:#{@import_sheet.id} imported:#{@import_sheet.imported.to_s}"
        format.html { render action: 'new', import_sheet: @import_sheet }
        format.json { render json: @import_sheet.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # PATCH/PUT /import_sheets/1
  # PATCH/PUT /import_sheets/1.json
  def update
    respond_to do |format|
      if @import_sheet.update(update_file_param(import_sheet_params))
        format.html {
          if @commit == :import
            redirect_to @import_sheet, notice: 'sheet was successfully imported.'
          else
            redirect_to edit_import_sheet_path(@import_sheet), notice: 'sheet was successfully uploaded.'
          end
        }
        format.json { head :no_content }
        format.js
      else
        logger.warn "import failed, id:#{@import_sheet.id} imported:#{@import_sheet.imported.to_s}"
        format.html { render action: 'edit' }
        format.json { render json: @import_sheet.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /import_sheets/1
  # DELETE /import_sheets/1.json
  def destroy
    @import_sheet.destroy
    respond_to do |format|
      format.html { redirect_to import_sheets_url }
      format.json { head :no_content }
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_import_sheet
      @import_sheet = ImportSheet.find(params[:id])
      @t = @import_sheet._target
    end

    def new_import_sheet
      @t = params[:_t] || "sale"
      model = "import_#{@t}".classify
      ImportSheet.new(store_id: @store_id, user_id: current_user.id, type: model)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def import_sheet_params
      params.require(:import_sheet).permit(:store_id, :type, :file_upload, :comment, :_do)
      #logger.debug "mapping step, :mapping is whitelist'd"
      #return params.require(:import_sheet).permit(:user_id, :step).tap do |whitelist|
      #  whitelist[:mapping] = params[:import_sheet][:mapping]
      #end
    end

    def update_file_param(param)
      # judge by commit param
      if @commit == :import
        param["_do"] = "import"
        param.delete "file_upload"
      end
      param
    end
end

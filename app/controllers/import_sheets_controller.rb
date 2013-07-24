class ImportSheetsController < ApplicationController
  before_action :set_import_sheet, only: [:show, :edit, :update, :destroy]
  respond_to :json

  # GET /import_sheets
  # GET /import_sheets.json
  def index
    @import_sheets = ImportSheet.all
  end

  # GET /import_sheets/1
  # GET /import_sheets/1.json
  def show
  end

  # GET /import_sheets/new
  def new
    @import_sheet = ImportSheet.new
  end

  # GET /import_sheets/1/edit
  def edit
  end

  # POST /import_sheets
  # POST /import_sheets.json
  def create
    @import_sheet = ImportSheet.new(import_sheet_params)

    respond_to do |format|
      if @import_sheet.save
        format.html { redirect_to @import_sheet, notice: 'Import sheet was successfully created.' }
        #format.json { render action: 'show', status: :created, location: @import_sheet }
        # format.json { render :json => "1"}
        format.js
      else
        format.html { render action: 'new', notice: @import_sheet.errors }
        format.json { render json: @import_sheet.errors, status: :unprocessable_entity }
        format.js { render :partial => 'error' }
      end
    end
  end

  # PATCH/PUT /import_sheets/1
  # PATCH/PUT /import_sheets/1.json
  def update
    logger.debug aaa
    respond_to do |format|
      if @import_sheet.update(import_sheet_params)
        format.html { redirect_to @import_sheet, notice: 'Import sheet was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @import_sheet.errors, status: :unprocessable_entity }
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
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_import_sheet
      @import_sheet = ImportSheet.find(params[:id])
    end

    def create_import_params
      params.require(:import_sheet).permit(:store_id, :user_id, :step, :comment, :upload_sheet)
    end

    def update_import_params
      case params[:import_sheet][:step]
      when "2" params.require(:import_sheet).permit(:user_id, :step, :sel_sheet, :to_category)
      when "3" params.require(:import_sheet).permit(:user_id, :step, :mapping)
      else nil
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def import_sheet_params
      params.require(:import_sheet).permit(:store_id, :user_id, :filename, :comment, :ext, :upload_sheet)
    end
end

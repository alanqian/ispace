=begin
import_sheet pages:
1. import_sheets.index, if import
   list successfully imported spreadsheet files;
2. import wizard(ajax)
   2.a import_sheets.new/create: upload file;
   2.b import_sheets.edit/update(step=2): choose sheet;
   2.c import_sheets.edit/update(step=3): set field mapping;
3. show import details:
   linked to results' page(brands, suppliers, manufactures, products, merchandises);
   params: category_id=?, import_id=?
   add discard link?
4. discard imported
   import_sheets.destroy  update(step=0): discard imported records
   TODO: check other related models? such as Plan?
=end

class ImportSheetsController < ApplicationController
  before_action :set_import_sheet, only: [:show, :edit, :update, :destroy]
  # respond_to :json

  # GET /import_sheets
  # GET /import_sheets.json
  def index
    if params[:static]
      logger.debug "import#static, don't show wizard, #{params[:static]}"
    end
    store_id = 1
    user_id = 1
    @import_sheets = ImportSheet.where([
      "store_id=? and user_id=? and (step=0 or step=4)", store_id, user_id])
  end

  # GET /import_sheets/1
  # GET /import_sheets/1.json
  def show
  end

  # GET /import_sheets/new
  def new
    @store_id = 1
    @user_id = 1
    @import_sheet = ImportSheet.new(step: 1, store_id: @store_id, user_id: @user_id)

    respond_to do |format|
      if params[:ajax]
        format.html { render partial: 'upload', locals: { import_sheet: @import_sheet }}
      else
        format.html
      end
    end
  end

  # GET /import_sheets/1/edit
  def edit
    respond_to do |format|
      case params[:ajax]
      when "chooseSheets"
        format.html { render partial: 'choose_sheets', locals: {
          import_sheet: @import_sheet,
          categories: Category.all,
        }}
      when "mapFields"
        format.html { render partial: 'map_fields', locals: {
          import_sheet: @import_sheet,
          to_fields: ImportSheet.mapping_fields,
          auto_mapping: ImportSheet.auto_mapping,
        }}
      else
        format.html
      end
    end
  end

  # POST /import_sheets
  # POST /import_sheets.json
  def create
    @import_sheet = ImportSheet.new(import_sheet_params)

    respond_to do |format|
      if @import_sheet.save
        format.html { redirect_to @import_sheet, notice: 'Import sheet was successfully created.' }
        format.json { render action: 'show', status: :created, location: @import_sheet }
        format.js
      else
        format.html { render action: 'new', notice: @import_sheet.errors }
        format.json { render json: @import_sheet.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # PATCH/PUT /import_sheets/1
  # PATCH/PUT /import_sheets/1.json
  def update
    respond_to do |format|
      if @import_sheet.update(import_sheet_params)
        format.html { redirect_to @import_sheet, notice: 'Import sheet was successfully updated.' }
        format.json { head :no_content }
        format.js do
          case @import_sheet.step
          when 3  # sheets updated
            render "update_sheets"
          when 4  # mapping updated
            render "update_mappings"
          else
            logger.debug "updated, but with incorrect step:#{@import_sheet.step}"
            "internal error, updated with incorrect step:#{@import_sheet.step}"
          end
        end
      else
        format.html { render action: 'edit' }
        format.json { render json: @import_sheet.errors, status: :unprocessable_entity }
        format.js do
          case @import_sheet.step
          when 2 # failed to update sheets
            render "update_sheets"
          when 3 # failed to update mappings
            render "update_mappings"
          else
            logger.debug "update failed, incorrect step:#{@import_sheet.step}"
            "internal error, update failed with incorrect step:#{@import_sheet.step}"
          end
        end
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def import_sheet_params
      logger.debug "step: #{params[:import_sheet][:step]}"
      case params[:import_sheet][:step]
      when 2,"2"
        logger.debug "choose sheet step"
        return params.require(:import_sheet).permit(:user_id, :step, :comment, :category_id, :sel_sheets => [])
      when 3,"3"
        logger.debug "mapping step, :mapping is whitelist'd"
        return params.require(:import_sheet).permit(:user_id, :step).tap do |whitelist|
          whitelist[:mapping] = params[:import_sheet][:mapping]
        end
        # logger.debug "whitelist param :mapping, form param: #{prm.to_json}"
        # return prm
      else
        logger.debug "upload step, step:#{params[:import_sheet][:step]}"
        return params.require(:import_sheet).permit(:store_id, :user_id, :comment, :upload_sheet)
        # logger.debug "form param: #{prm.to_json}"
        # return prm
      end
      # params.require(:import_sheet).permit(:store_id, :user_id, :filename, :comment, :ext, :upload_sheet)
    end
end

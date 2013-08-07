=begin
product pages:

1: products.index
  brands.index
  manufactures.index
  suppliers.index:
  products.index:
  merchandises.index:
  -------------
  import_sheets.index, include import wizard;

2 products.import?

3. products.edit

4. products.destroy

=end
class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  # Product List
  # GET /products
  # GET /products.json
  def index
    @store_id = 1
    @user_id = 1
    @products = Product.all
    @new_import = ImportSheet.new(step: 1, store_id: @store_id, user_id:
                                    @user_id)
    @choose_sheets = ImportSheet.where(store_id: @store_id, step: 2)
    @categories = Category.all

    @mapping_sheets = ImportSheet.where(store_id: @store_id, step: 3)
    @auto_mapping = ImportSheet.auto_mapping
    @to_fields = ImportSheet.mapping_fields # @auto_mapping.values.uniq
  end

  # POST /products/import
  # import process:
  #   1. upload
  #      save sheet/header/cells info of uploaded file,
  #      ok => import?step=2, choose-sheet
  #      fail => import?step=1, show error;
  #   2. choose sheet of files if necessary
  #      sheet -> category => import?step=3, sheet =
  #   3. set file mapping
  #      file/sheet:
  #      headers -> fields
  #   4. finish, show recent 10 import results
  #
  def import
    @import = Import.new(sheet_params)
    if @import.save
      redirect_to(action: 'show', id: @import.id)
    else
      redirect_to(action: 'get')
    end
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render action: 'show', status: :created, location: @product }
      else
        format.html { render action: 'new' }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:category_id, :brand_id, :mfr_id, :user_id, :id, :name, :height, :width, :depth, :weight, :price_level, :size_name, :case_pack_name, :bar_code, :color)
    end

    def sheet_params
      params.require(:import).permit(:upload_sheet, :store_id, :user_id)
    end
end

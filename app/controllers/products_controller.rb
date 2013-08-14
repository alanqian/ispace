=begin "interfaces of :product"

1. list
   brands/
   manufactures/
   suppliers/
   products/
   merchandises/

   filter: by import_id; by: category; all/self_store/branches/ only?
   ui: resizable table view + inplace edit, esp. color edit

2. import_sheets
   import_sheets/
   import_sheets/new?ajax=wizard

3. merchandise metrics(self store only):
   filter by: category, store_id
   width/depth/height/color/facings/
   with previews of placing info;

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
end

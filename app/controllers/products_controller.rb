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
    category_id = params[:category]
    if category_id
      @products = Product.where([
        "category_id=?", category_id])
      product_new = Product.new(category_id: category_id)
      brands_all = Brand.where(category_id: category_id)
      mfrs_all = Manufacturer.where(category_id: category_id)
    else
      @products = Product.all
      product_new = Product.new(category_id: category_id)
      brands_all = Brand.all
      mfrs_all = Manufacturer.all
    end
    render 'index', locals: {
      categories_all: Category.all,
      brands_all: brands_all,
      mfrs_all: mfrs_all,
      product_new: product_new,
    }
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new(category_id: params[:category])
    render 'new', locals: { categories: Category.all }
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
        format.js
      else
        format.html { render action: 'new' }
        format.json { render json: @product.errors, status: :unprocessable_entity }
        format.js
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
        format.js {
          @brands_hash = view_context.rel_hash(Brand.where(category_id: @product.category_id), :id, :name)
          @mfrs_hash = view_context.rel_hash(Manufacturer.where(category_id: @product.category_id), :id, :name)
        }
      else
        format.html { render action: 'edit' }
        format.json { render json: @product.errors, status: :unprocessable_entity }
        format.js {
          @brands_hash = view_context.rel_hash(Brand.where(category_id: @product.category_id), :id, :name)
          @mfrs_hash = view_context.rel_hash(Manufacturer.where(category_id: @product.category_id), :id, :name)
        }
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

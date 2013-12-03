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
  load_and_authorize_resource

  # Product List
  # GET /products
  # GET /products.json
  def index
    # @current_user_store_id
    category_id = params[:category] || Category.default_id

    if @do == :on_shelf
      @products = Product.under(category_id).on_shelf
    else
      @products = Product.under(category_id)
    end
    render 'index', locals: {
      brands_all: Brand.under(category_id).select(:id, :name),
      mfrs_all: Manufacturer.under(category_id).select(:id, :name),
      suppliers_all: Supplier.under(category_id).select(:id, :name),
      product_new: Product.new(category_id: category_id),
    }
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new(category_id: params[:category])
    render 'new', locals: {
      categories_all: Category.all,
      brands_all: Brand.select("category_id, id, name"),
      suppliers_all: Supplier.select("category_id, id, name"),
      mfrs_all: Manufacturer.select("category_id, id, name")
    }
  end

  # GET /products/1/edit
  def edit
    render 'edit', locals: {
      categories_all: Category.all,
      brands_all: Brand.select("category_id, id, name"),
      suppliers_all: Supplier.select("category_id, id, name"),
      mfrs_all: Manufacturer.select("category_id, id, name")
    }
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)
    @product.user_id = @current_user_id

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

  # PATCH/PUT /products/
  def update_ex
    @products = params[:products]
    if @products.any?
      logger.debug "#{@products}, #{product_attr_params}"
      products = Product.where(code: @products).update_all(product_attr_params)
      respond_to do |format|
        format.html {
          redirect_to products_url, notice: simple_notice(count: @products.size)
        }
        format.js {
          set_products_ex_js
        }
      end
    else
      logger.error "no product has been selected!"
      respond_to do |format|
        format.html { redirect_to products_url, notice: simple_notice(message: :update_fail) }
        format.js
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update_default
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { head :no_content }
        format.js {
          logger.debug "updated, ctg:#{@product.category_id}, brand: #{@product.brand_id}"
          set_product_update_js
        }
      else
        format.html { render action: 'edit' }
        format.json { render json: @product.errors, status: :unprocessable_entity }
        format.js {
          set_product_update_js
          logger.debug "update failed, ctg:#{@product.category_id}, brand: #{@product.brand_id}"
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
      if params[:id] != "[]"
        @product = Product.find(params[:id])
      end
    end

    def set_products_ex_js
      @product = Product.find(@products.first)
      @products_hash = Hash[Product.where(code: @products).map {|r| [r.id, r]} ]
      @brands_hash = Brand.where(category_id: @product.category_id).to_hash(:id, :name)
      @suppliers_hash = Supplier.where(category_id: @product.category_id).to_hash(:id, :name)
      @mfrs_hash = Manufacturer.where(category_id: @product.category_id).to_hash(:id, :name)
    end

    def set_product_update_js
      @brands_hash = Brand.where(category_id: @product.category_id).to_hash(:id, :name)
      @suppliers_hash = Supplier.where(category_id: @product.category_id).to_hash(:id, :name)
      @mfrs_hash = Manufacturer.where(category_id: @product.category_id).to_hash(:id, :name)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:_do, :user_id, :category_id, :code, :brand_id,
        :mfr_id, :supplier_id, :id, :name, :height, :width, :depth, :weight, :price_zone,
        :size_name, :case_pack_name, :barcode, :color,
        :grade, :new_product, :on_promotion)
    end

    def product_attr_params
      params.require(:product).permit(:grade, :new_product, :on_promotion)
    end
end

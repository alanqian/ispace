=begin "interfaces of :suppliers"

1. /suppliers/: combo-list with inplace edit, batch new
  filter: select category

2. /suppliers/1: PATCH
  ajax update by in-place edit

3. /suppliers: POST
  batch mode new, redirect to index

4. inplace color picker
  fire a click on color picker span if click on the proper td

=end

class SuppliersController < ApplicationController
  before_action :set_supplier, only: [:show, :edit, :update, :destroy]

  # GET /suppliers
  # GET /suppliers.json
  def index
    category_id = params[:category] || Category.default_id
    @suppliers = Supplier.where([
      "category_id=?", category_id])
    supplier_new = Supplier.new(category_id: category_id)
    render 'index', locals: { categories: Category.all, supplier_new: supplier_new }
  end

  # GET /suppliers/1
  # GET /suppliers/1.json
  def show
  end

  # GET /suppliers/new
  def new
    @supplier = Supplier.new(category_id: params[:category])
    render 'new', locals: { categories: Category.all }
  end

  # GET /suppliers/1/edit
  def edit
    render 'edit', locals: { categories: Category.all }
  end

  # POST /suppliers
  # POST /suppliers.json
  def create
    @supplier = Supplier.new(supplier_params)

    # check the whole input at first, for all attributes
    @supplier.valid?

    # validate the splited names
    columns = [:category_id, :name]
    values = []
    names = @supplier.name.split(/\r?\n/).map {|n| n.strip } .keep_if {|n| !n.empty?}
    names.each do |name|
      errors = Supplier.validate_attribute(:name, name)
      if errors.any?
        @supplier.errors[:name].concat(errors)
      else
        values << [@supplier.category_id, name]
      end
    end

    respond_to do |format|
      if @supplier.errors.any?
        logger.warn "create.import failed, category:#{@supplier.category_id}"
        format.html { render action: 'new', locals: { categories: Category.all } }
        format.json { render json: @supplier.errors, status: :unprocessable_entity }
      else
        # still need validate to ensure the records
        # supplier.import will filter the dup records automatically
        Supplier.import(columns, values)
        logger.debug "create.import ok, category:#{@supplier.category_id}"
        format.html { redirect_to suppliers_url(category: @supplier.category_id) }
        format.json { render action: 'show', status: :created, location: @supplier }
      end
    end
  end

  # PATCH/PUT /suppliers/1
  # PATCH/PUT /suppliers/1.json
  def update
    respond_to do |format|
      if @supplier.update(supplier_params)
        format.html { redirect_to @supplier, notice: 'Supplier was successfully updated.' }
        format.json { head :no_content }
        format.js
      else
        format.html { render action: 'edit' }
        format.json { render json: @supplier.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /suppliers/1
  # DELETE /suppliers/1.json
  def destroy
    @supplier.destroy
    respond_to do |format|
      format.html { redirect_to suppliers_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_supplier
      @supplier = Supplier.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def supplier_params
      params.require(:supplier).permit(:name, :category_id, :desc, :color)
    end
end

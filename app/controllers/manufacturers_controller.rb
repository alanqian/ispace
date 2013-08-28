=begin "interfaces of :manufacturers"

1. /manufacturers/: combo-list with inplace edit, batch new
  filter: select category

2. /manufacturers/1: PATCH
  ajax update by in-place edit

3. /manufacturers: POST
  batch mode new, redirect to index

4. inplace color picker
  fire a click on color picker span if click on the proper td

=end
class ManufacturersController < ApplicationController
  before_action :set_manufacturer, only: [:show, :edit, :update, :destroy]

  # GET /manufacturers
  # GET /manufacturers.json
  def index
    category_id = params[:category] || Category.default_id
    @manufacturers = Manufacturer.where([
      "category_id=?", category_id])
    manufacturer_new = Manufacturer.new(category_id: category_id)
    render 'index', locals: {
      categories: Category.all,
      manufacturer_new: manufacturer_new
    }
  end

  # GET /manufacturers/1
  # GET /manufacturers/1.json
  def show
  end

  # GET /manufacturers/new
  def new
    @manufacturer = Manufacturer.new(category_id: params[:category])
    render 'new', locals: { categories: Category.all }
  end

  # GET /manufacturers/1/edit
  def edit
  end

  # POST /manufacturers
  # POST /manufacturers.json
  def create
    # @manufacturer = Manufacturer.new(manufacturer_params)
    @manufacturer = Manufacturer.new(manufacturer_params)

    # check the whole input at first, for all attributes
    @manufacturer.valid?

    # validate the splited names
    columns = [:category_id, :name]
    values = []
    names = @manufacturer.name.split(/\r?\n/).map {|n| n.strip } .keep_if {|n| !n.empty?}
    names.each do |name|
      errors = Manufacturer.validate_attribute(:name, name)
      if errors.any?
        @manufacturer.errors[:name].concat(errors)
      else
        values << [@manufacturer.category_id, name]
      end
    end

    respond_to do |format|
      if @manufacturer.errors.any?
        logger.warn "create.import failed, category:#{@manufacturer.category_id}"
        format.html { render action: 'new', locals: { categories: Category.all } }
        format.json { render json: @manufacturer.errors, status: :unprocessable_entity }
      else
        # still need validate to ensure the records
        # manufacturer.import will filter the dup records automatically
        Manufacturer.import(columns, values)
        logger.debug "create.import ok, category:#{@manufacturer.category_id}"
        format.html { redirect_to manufacturers_url(category: @manufacturer.category_id) }
        format.json { render action: 'show', status: :created, location: @manufacturer }
      end
    end
  end

  # PATCH/PUT /manufacturers/1
  # PATCH/PUT /manufacturers/1.json
  def update
    respond_to do |format|
      if @manufacturer.update(manufacturer_params)
        format.html { redirect_to @manufacturer, notice: 'Manufacturer was successfully updated.' }
        format.json { head :no_content }
        format.js
      else
        format.html { render action: 'edit' }
        format.json { render json: @manufacturer.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /manufacturers/1
  # DELETE /manufacturers/1.json
  def destroy
    @manufacturer.destroy
    respond_to do |format|
      format.html { redirect_to manufacturers_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_manufacturer
      @manufacturer = Manufacturer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def manufacturer_params
      params.require(:manufacturer).permit(:name, :category_id, :desc, :color)
    end
end

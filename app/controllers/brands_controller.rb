=begin "interfaces of :brands"

1. /brands/: combo-list with inplace edit, batch new
  filter: select category
  filter: select
  resizable table view, auto paginate
  in-place edit

  in-place edit implementation:
  $(table).inplaceEdit() ->
    init ->
      template: $()
      fields: [field-name-1, null, field-name-2, null, ...]
    tr.click ->
      if not same row
        wrap td value with <span>, hidden
        mv template input into td
        change value of input
        change width, height of input
    TODO: input.blur
      if out of this tr
        ajax update ->
        hide template inputs, move out of tds (before thread)
        replace tr with new value(ajax return) and show

  field-mapping:
    <table data-form="#form-id-name">
      <th data-input="field-name">
      <th data-select="field-name">
    <tr data-id="record-id">
      <td data-val="value">
      <td>value</td>

2. /brands/1: PATCH
  ajax update by in-place edit

3. /brands: POST
  batch mode new, redirect to index

4. inplace color picker
  fire a click on color picker span if click on the proper td

=end

class BrandsController < ApplicationController
  before_action :set_brand, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /brands
  # GET /brands.json
  def index
    category_id = params[:category] || Category.default_id
    @brands = Brand.where(["category_id=?", category_id])
    brand_new = Brand.new(category_id: category_id)
    render 'index', locals: { categories: Category.all, brand_new: brand_new }
  end

  # GET /brands/1
  # GET /brands/1.json
  def show
  end

  # GET /brands/new
  def new
    @brand = Brand.new(category_id: params[:category])
    render 'new', locals: { categories: Category.all }
  end

  # GET /brands/1/edit
  def edit
    render 'edit', locals: { categories: Category.all }
  end

  # POST /brands
  # POST /brands.json
  def create
    @brand = Brand.new(brand_params)

    # check the whole input at first, for all attributes
    @brand.valid?

    # validate the splited names
    columns = [:category_id, :name]
    values = []
    names = @brand.name.split(/\r?\n/).map {|n| n.strip } .keep_if {|n| !n.empty?}
    names.each do |name|
      errors = Brand.validate_attribute(:name, name)
      if errors.any?
        @brand.errors[:name].concat(errors)
      else
        values << [@brand.category_id, name]
      end
    end

    respond_to do |format|
      if @brand.errors.any?
        logger.warn "create.import failed, category:#{@brand.category_id}"
        format.html { render action: 'new', locals: { categories: Category.all } }
        format.json { render json: @brand.errors, status: :unprocessable_entity }
      else
        # still need validate to ensure the records
        # Brand.import will filter the dup records automatically
        Brand.import(columns, values)
        logger.debug "create.import ok, category:#{@brand.category_id}"
        format.html { redirect_to brands_url(category: @brand.category_id) }
        format.json { render action: 'show', status: :created, location: @brand }
      end
    end
  end

  # PATCH/PUT /brands/1
  # PATCH/PUT /brands/1.json
  def update
    respond_to do |format|
      if @brand.update(brand_params)
        format.html { redirect_to @brand, notice: 'Brand was successfully updated.' }
        format.json { head :no_content }
        format.js
      else
        format.html { render action: 'edit' }
        format.json { render json: @brand.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /brands/1
  # DELETE /brands/1.json
  def destroy
    @brand.destroy
    respond_to do |format|
      format.html { redirect_to brands_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_brand
      @brand = Brand.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def brand_params
      params.require(:brand).permit(:name, :category_id, :color)
    end
end

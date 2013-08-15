=begin "interfaces of :brands"

/brands/
  filter: select category
  filter: select
  resizable table view, auto paginate
  in-place edit: bind form to tr

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
    input.blur
      if out of this tr
        ajax update ->
        hide template inputs, move out of tds (before thread)
        replace tr with new value(ajax return) and show

  field-mapping:
    <th data-input="field-name">
  id:
    <th data-input="id"> or <tr data-id="record-id">
  eg:
    <form ...>
    <input id="brand_name" name="brand[name]" size="50">
    <input ...>
    </form>

/brands/1:  in-place edit template
  color-edit

=end

class BrandsController < ApplicationController
  before_action :set_brand, only: [:show, :edit, :update, :destroy]

  # GET /brands
  # GET /brands.json
  def index
    category_id = params[:category]
    if category_id
      @brands = Brand.where([
        "category_id=?", category_id])
      brand_new = Brand.new(category_id: category_id)
    else
      @brands = []
      brand_new = Brand.new()
    end
    render 'index', locals: { categories: Category.all, brand_new: brand_new }
  end

  # GET /brands/1
  # GET /brands/1.json
  def show
  end

  # GET /brands/new
  def new
    @brand = Brand.new
  end

  # GET /brands/1/edit
  def edit
  end

  # POST /brands
  # POST /brands.json
  def create
    @brand = Brand.new(brand_params)

    respond_to do |format|
      if @brand.save
        format.html { redirect_to @brand, notice: 'Brand was successfully created.' }
        format.json { render action: 'show', status: :created, location: @brand }
      else
        format.html { render action: 'new' }
        format.json { render json: @brand.errors, status: :unprocessable_entity }
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
      else
        format.html { render action: 'edit' }
        format.json { render json: @brand.errors, status: :unprocessable_entity }
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

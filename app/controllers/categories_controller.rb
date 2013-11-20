class CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /categories
  # GET /categories.json
  def index
    @categories = Category.all.order(:code)
    render "index", locals: {
      category_new: Category.new,
      num_main_ctg: @categories.to_a.count { |c| c.code.length <= 2 },
      num_sub_ctg: @categories.to_a.count { |c| 3 == c.code.length || c.code.length == 4 },
    }
  end

  # GET /categories/1
  # GET /categories/1.json
  def show
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  # POST /categories.json
  def create
    @category = Category.new(category_params)

    respond_to do |format|
      if @category.save
        format.html { redirect_to @category, notice: 'Category was successfully created.' }
        format.json { render action: 'show', status: :created, location: @category }
      else
        format.html { render action: 'new' }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/1
  # PATCH/PUT /categories/1.json
  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to @category, notice: 'Category was successfully updated.' }
        format.json { head :no_content }
        format.js { set_category_update_js }
      else
        format.html { render action: 'edit' }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    @category.destroy
    respond_to do |format|
      format.html { redirect_to categories_url }
      format.json { head :no_content }
    end
  end

  def manage
    logger.debug "manage categories..."
    @categories = Category.paginate page: params[:page], per_page: 10
    respond_to do |format|
      format.html
    end
  end

  def bulk_update
    # TODO:
    flash[:notice] = "updated"
    redirect_to manage_path(:page => params[:page])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      logger.debug "set_category callback"
      @category = Category.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:category).permit(:code, :name, :parent_id, :memo)
    end

    def set_category_update_js
      @category.reload
    end
end

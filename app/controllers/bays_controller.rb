require 'json'

class BaysController < ApplicationController
  before_action :set_bay, only: [:show, :edit, :update, :destroy]
  before_action :set_extra, only: [:show, :edit]
  before_filter :set_expires

  # GET /bays
  # GET /bays.json
  def index
    @bays = Bay.all
  end

  # GET /bays/1
  # GET /bays/1.json
  def show
  end

  # GET /bays/new
  def new
    @bay = Bay.template
    set_extra
  end

  # GET /bays/1/edit
  def edit
  end

  # POST /bays
  # POST /bays.json
  def create
    @bay = Bay.new(bay_params)

    respond_to do |format|
      if @bay.save
        format.html { redirect_to @bay, notice: 'Bay was successfully created.' }
        format.json { render action: 'show', status: :created, location: @bay }
        #format.json { render json: @bay, methods: [:open_shelves, :peg_boards, :freezer_chests, :rear_support_bars,] }
      else
        logger.error "create failed, #{@bay.errors.to_json}"
        format.html {
          set_extra
          render action: 'new'
        }
        format.json { render json: @bay.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bays/1
  # PATCH/PUT /bays/1.json
  def update
    respond_to do |format|
      if @bay.update(bay_params)
        format.html { redirect_to @bay, notice: 'Bay was successfully updated.' }
        format.json { head :no_content }
      else
        logger.error "update failed, #{@bay.errors.to_json}"
        format.html {
          set_extra
          render action: 'edit'
        }
        format.json { render json: @bay.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bays/1
  # DELETE /bays/1.json
  def destroy
    @bay.destroy
    respond_to do |format|
      format.html { redirect_to bays_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bay
      @bay = Bay.find(params[:id])
    end

    def set_extra
      # set template members
      @templates = [
        ["open_shelf", :open_shelves, OpenShelf.template(@bay)],
        ["peg_board", :peg_boards, PegBoard.template(@bay)],
        ["freezer_chest", :freezer_chests, FreezerChest.template(@bay)],
        ["rear_support_bar", :rear_support_bars, RearSupportBar.template(@bay)],
      ]
    end

    # run = back_width
    # linear = Σ(shelf_width)
    # area = Σ(shelf_width * shelf_height)
    # cube = Σ(shelf_width * shelf_height * shelf_depth)
    def recalc_bay_space(bay_params)
      linear = 0.0
      area = 0.0
      cube = 0.0
      if bay_params.has_key?(:open_shelves_attributes)
        bay_params[:open_shelves_attributes].each do |_, el|
          if el[:_destroy] == "false"
            width, height, depth = [:width, :height, :depth].map { |f| el[f].to_f }
            linear += width
            area += width * height
            cube += width * height * depth
          end
        end
      end
      bay_params[:linear] = linear
      bay_params[:area] = area
      bay_params[:cube] = cube
      bay_params
    end

    def normalize_params(bay_params)
      # NOTE: all values in bay_params is String
      elem_exists = lambda { |pair| pair[1][:_destroy] == "false" }

      if bay_params.permitted?
        # update elem_type, elem_count correctly
        elem_type = 0
        bay_params[:elem_type] = 0 # TODO: check mixed type
        bay_params[:elem_count] = 0
        notch_spacing = bay_params[:notch_spacing].to_f || 1.0
        notch_1st = bay_params[:notch_1st].to_f || 1.0
        [:open_shelves_attributes, :peg_boards_attributes, :freezer_chests_attributes,
          :rear_support_bars_attributes].each do |nested|
          attrs = bay_params[nested]
          if attrs
            bay_params[:elem_type] |= (1 << elem_type)
            bay_params[:elem_count] += attrs.count(&elem_exists)
          end
          elem_type += 1
        end
      end
      bay_params
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bay_params
      recalc_bay_space normalize_params params.require(:bay).permit(
        :name, :back_height, :back_width, :back_thick, :back_color,
        :use_notch, :notch_spacing, :notch_1st,
        :base_height, :base_width, :base_depth, :base_color,
        :takeoff_height, :elem_type, :elem_count,
        :show_peg_holes,
        open_shelves_attributes: [:_destroy, :id, :name, :level,
          :height, :width, :depth, :thick,
          :slope, :riser, :notch_num, :from_base, :color, :from_back,
          :finger_space, :x_position, ],
        peg_boards_attributes: [:_destroy, :id, :name, :level,
          :height, :depth,
          :vert_space, :horz_space, :vert_start, :horz_start,
          :notch_num, :from_base, :color,],
        freezer_chests_attributes: [:_destroy, :id, :name, :level,
          :height, :depth, :wall_thick,
          :inside_height, :merch_height,
          :color, ],
        rear_support_bars_attributes: [:_destroy, :id, :name, :level,
          :height, :bar_depth, :bar_thick,
          :from_back, :hook_length,
          :notch_num, :from_base, :color, :bar_slope, ],
      )
    end

    def set_expires
      expires_now
    end
end

__END__

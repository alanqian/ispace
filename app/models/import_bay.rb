# encoding: utf-8
class ImportBay < ImportSheet
  def on_upload
    self.imported[:count] = {
      :bay => 0,
    }
  end

  def start_import?(sheet)
    @count = 0
    @common = {
      user_id: self.user_id,
    }
    @bay_params = {
      base_color: "#400040",
      back_color: "#ffffff",
      open_shelves: [],
    }
  end

  def get_element_params(element_name, sizes, count)
    if element_name =~ /主框架/
      params = {
        back_height: sizes.height,
        back_width: sizes.length,
        back_thick: 0,
        base_width: sizes.length,
        base_height: 0,
        base_depth: 0,
        total_depth: sizes.width,
      }
    elsif element_name =~ /层板/
      params = {
        open_shelves: {
          name: element_name,
          width: sizes.length,
          depth: sizes.width,
          thick: sizes.height,
          layers: count.to_i
        }
      }
    elsif element_name =~ /横杆/
      params = {
        rear_support_bars: {
          bar_depth: sizes.width,
          bar_thick: sizes.height,
          layers: count.to_i
        }
      }
    elsif element_name =~ /挂钩/
      params = {
        rear_support_bars: {
          name: element_name,
          hook_length: sizes.length,
        }
      }
    else
      logger.warn "Unknown element, name:#{element_name}"
      nil
    end
  end

  @@rsb = {
    color: "#dfdfdf",
    bar_slope: 0,
    from_back: 0,
  }
  @@open_shelf = {
    name: "shelf",
    height: 0,
    notch_num: 0,
    from_base: 0,

    slope: 0,
    riser: 0,
    color: "#dfdfdf",
    from_back: 0,
    finger_space: 40,
    x_position: 0,
  }

  # output: {:name=>"905层板型中岛柜", :back_height=>1380, :back_width=>905,
  #  :back_thick=>0, :base_width=>905, :base_height=>0, :base_depth=>0,
  #  :open_shelves=>{:width=>903, :depth=>315, :thick=>107, :layers=>"4"}}
  def create_bay
    return unless @bay_params.key?(:back_thick)

    open_shelves = @bay_params.delete(:open_shelves).sort {|a, b| b[:depth] <=> a[:depth]}
    rsb = @bay_params.delete(:rear_support_bars)
    elem_count = open_shelves.sum() { |e| e[:layers] }
    elem_count += rsb[:layers] if rsb
    elem_count += 1 if elem_count == 0
    avg_height = @bay_params[:back_height] / elem_count

    level = 1
    notch_num = 1
    if open_shelves.any?
      attrs = {}
      open_shelves.each do |e|
        e[:thick] = [e[:thick], 30].min
        e[:height] = avg_height - e[:thick] - 40
        layers = e.delete(:layers)
        layers.times do |i|
          name = "#{level}. #{e[:name]}"
          e[:level] = level
          e[:notch_num] = notch_num
          e[:from_base] = notch_num * 20
          attrs[level] = @@open_shelf.merge(e).merge(name: name)
          level += 1
          notch_num += avg_height / 20
        end
      end
      @bay_params[:open_shelves_attributes] = attrs
    end

    if rsb && rsb[:layers] > 0
      rsb_attrs = {}
      layers = rsb.delete(:layers)
      from_back = 10 + (layers - 1) * rsb[:hook_length]
      rsb[:height] = avg_height - rsb[:bar_thick]
      layers.times do |i|
        notch_num += avg_height / 20
        name = "#{level}. #{rsb[:name]}"
        rsb[:notch_num] = notch_num
        rsb[:from_base] = notch_num * 20
        rsb[:from_back] = from_back
        rsb[:level] = level
        rsb_attrs[level] = @@rsb.merge(rsb).merge(name: name)
        level += 1
        from_back -= rsb[:hook_length]
      end
      @bay_params[:rear_support_bars_attributes] = rsb_attrs
    end

    # check double side, calc base_depth, back_thick
    total_depth = @bay_params.delete(:total_depth)
    if @bay_params[:name] =~ /中岛/
      # double side
      total_depth /= 2
    end
    @bay_params[:base_depth] = total_depth
    @bay_params[:back_thick] = 30
    @bay_params[:base_height] = 50
    @bay_params[:back_height] -= 50

    logger.debug "Bay.create #{@bay_params.to_s}"
    bay = Bay.create(@bay_params)
    if bay.id.nil?
      logger.debug "errors: #{bay.errors.to_json}"
    end
    @bay_params = {
      base_color: "#400040",
      back_color: "#ffffff",
      open_shelves: [],
    }
  end

  # params:{"bay":{"name":"905层板型中岛柜","element":"主框架","sizes":"905×650×1380","elem_count":"1"}}
  # params:{"bay":{"element":"200长层板","sizes":"903×215×107","elem_count":"4"}}
  # params:{"bay":{"element":"300长层板","sizes":"903×315×107","elem_count":"4"}}
  def import_row(params, row_index)
    #logger.debug "import #{row_index}, params:#{params.to_s}"
    params = params[:bay]
    sz = nil
    if params && params[:name]
      if @bay_params.any?
        create_bay
      end
      # update name
      @bay_params[:name] = params[:name]
    end
    if params && params[:sizes]
      sizes = params[:sizes].split(/[*×xX]/)
      if sizes.size == 3
        sz = OpenStruct.new
        sz.length = sizes[0].to_i
        sz.width = sizes[1].to_i
        sz.height = sizes[2].to_i
      end
    end
    if sz
      param = get_element_params(params[:element], sz, params[:elem_count])
      if param
        if param.key?(:rear_support_bars) && @bay_params.key?(:rear_support_bars)
          @bay_params[:rear_support_bars].merge!(param[:rear_support_bars])
        elsif param.key?(:open_shelves)
          @bay_params[:open_shelves] ||= []
          @bay_params[:open_shelves].push param[:open_shelves]
        else
          @bay_params.merge!(param)
        end
      end
    end
    return true
  end

  def end_import(sheet)
    create_bay
    @count = 0
  end

  def self.map_dict
    @@dict
  end

  def self.import_tables
    imports = {
      :sale => Bay,
    }
  end

  @@dict = load_dict("import_bays")
end

class Fixture < ActiveRecord::Base
  has_many :fixture_items, -> { order(:item_index) }, dependent: :destroy
  accepts_nested_attributes_for :fixture_items, allow_destroy: true

  def deep_copy(uid)
    # copy self
    new_fixture = self.dup # shallow copy
    new_fixture.name += "(copy)"
    new_fixture.user_id = user_id
    new_fixture.save!

    # copy associations
    copy_assoc_to(new_fixture, :fixture_items)

    new_fixture
  end

  def deploy_to(store_id, category_id, fixture_code)
    StoreFixture.create({
      fixture_id: self.id,
      store_id: store_id,
      category_id: category_id,
      code: fixture_code,
    })
  end

  def calc_size
    fixture_items.each do |fi|
      num_bays = fi.num_bays
      bay = fi.bay
    end
  end

  # new_page, set scale/origin
  def new_pdf_page(pdf, ostate)
    case ostate.fixture[:output]
    when :front_and_side_view
      # front view in upper area, small view, 1/3 height
      # side view in below area, with detailed number, 2/3 height
      ostate.origin[0] = 0.0
      ostate.origin[1] = 50.0
      ostate.scale = 0

      full_width = 0
      full_depth = 0
      full_height = 0
      count = fixture_items.size
      fixture_items.each do |fi|
        logger.debug "origin 1: #{ostate.origin.to_s}"
        full_width += fi.bay.max_width * fi.num_bays
        full_depth += fi.bay.max_depth
        full_height = [full_height, fi.bay.max_height].max
      end

      pdf.new_page
      bbox = pdf.bounds
      ratio1 = 1 / 3.0
      ratio2 = 1 - ratio1
      y = [bbox.top, bbox.top * ratio1, bbox.top * ratio2, bbox.top * ratio2]
      x = [bbox.left, bbox.right]
      pdf.dash(2, :space => 2)
      pdf.stroke_rectangle([x[0], y[0]], x[1], y[1])
      pdf.stroke_rectangle([x[0], y[2]], x[1], y[3])
      pdf.undash

      # calculate scale/origin for top: full front view
      ostate.scale = []
      ostate.origin = []

      w = bbox.right
      h = y[1]
      scale = [w / full_width, h / full_height].min
      x0 = (w - full_width * scale) / 2
      y0 = y[2] + (h - full_height * scale) / 2
      ostate.scale.push scale
      ostate.origin.push [x0, y0]

      # calculate scale/origin for bottom: side view
      h = y[3]
      extra = ostate.options[:bay_left_width] * count + ostate.options[:bay_spacing] * (count - 1)

      scale = [(w - extra)/ full_depth, h / full_height].min
      x0 = (w - extra - full_depth * scale) / 2
      y0 = (h - full_height * scale) / 2
      ostate.scale.push scale
      ostate.origin.push [x0, y0]
      logger.debug "scale: #{ostate.scale.to_s} origin: #{ostate.origin.to_s}"

    when :front_view # show fixtures, one bay per page
      bay = ostate.fixture[:_bay]
      width = bay.max_width
      height = bay.max_height
      pdf.new_page(width >= height ? :landscape : :portrait)
      bbox = pdf.bounds
      ostate.scale = scale = [bbox.right / width, bbox.top / height].min
      ostate.origin[0] = (bbox.right - width * scale) / 2
      ostate.origin[1] = (bbox.top - height * scale) / 2
      logger.debug ":front_view, origin: #{ostate.origin.to_s}, scale: #{ostate.scale}, width: #{width}, height:#{height}"

    when :front_view_full # show whole fixture in a single page
      # calc scale
      spaces = shelf_spaces
      width = 0
      height = 0
      spaces.each do |item, space|
        width += space[:width] * space[:num_bays]
        height = space[:height] if height < space[:height]
      end

      pdf.new_page(width >= height ? :landscape : :portrait)

      bbox = pdf.bounds
      ostate.scale = scale = [bbox.right / width, bbox.top / height].min

      # calculate origin
      flow_size = 30
      ostate.origin[0] = (bbox.right - width * scale) / 2
      ostate.origin[1] = (bbox.top - flow_size - height * scale) / 2
    else
      pdf.new_page
      bbox = pdf.bounds
      ostate.scale = 1.0
      ostate.origin[0] = bbox.left
      ostate.origin[1] = bbox.bottom
    end
    pdf.page_count
  end

  def to_pdf(pdf, ostate)
    start_page = nil
    case ostate.fixture[:output]
    when :merchandise
      positions = ostate.positions
      start_page = new_pdf_page(pdf, ostate)
      fields = ostate.options[:mdse_fields]

      layer_name = {}
      fixture_items.each do |fi|
        bay = fi.bay
        bay.layers.each do |layer|
          key = Position.layer_key(fi.fixture_id, layer.layer)
          flow = self.flow_l2r ? ">>" : "<<"
          layer_name[key] = layer.get_layer_info_text("#{flow} #{self.name} #{flow}")
        end
      end

      pdf.font(ostate.options[:label_font]) do
        positions.each do |key, blocks|
          #logger.debug "#{key}, #{blocks.first.layer}"
          pdf.move_down 10
          pdf.text layer_name[key]
          pdf.move_down 10
          tdata = [ostate.options[:mdse_fields_name]]
          tdata.concat blocks.map { |block| fields.map { |f| block.send(f) } }
          pdf.table(tdata,
            cell_style: { borders: [], },
            header: true) do
            style(rows(0), :borders => [:top, :bottom])
          end
        end
      end

    when :front_and_side_view
      # front view in upper area, small view
      start_page = new_pdf_page(pdf, ostate)
      scale = ostate.scale.dup
      origin = ostate.origin.dup

      ostate.scale = scale.shift
      ostate.origin = origin.shift
      ostate.fixture[:bay] = :front_view
      fixture_items.each do |fi|
        num_bays = fi.num_bays
        bay = fi.bay
        ostate.fixture[:fixture_item_id] = fi.id
        ostate.fixture[:num_bays] = num_bays
        bay.to_pdf(pdf, ostate)
        bay_width = bay.max_width * num_bays * ostate.scale

        # for next fixture item
        ostate.origin[0] += bay_width
      end

      # side view in below area, with detailed numbers
      ostate.scale = scale.shift
      ostate.origin = origin.shift
      ostate.fixture[:bay] = :side_view
      fixture_items.each do |fi|
        bay = fi.bay
        bay.to_pdf(pdf, ostate)
        # for next fixture item
        ostate.origin[0] += bay.max_depth * ostate.scale
      end

    when :front_view # show fixtures, one bay per page
      # draw bays of fixture
      fixture_items.each do |fi|
        logger.debug "origin 1: #{ostate.origin.to_s}"
        num_bays = fi.num_bays
        ostate.fixture[:_bay] = bay = fi.bay

        ostate.fixture[:fixture_item_id] = fi.id
        ostate.fixture[:num_bays] = 1 # one bay per page
        num_bays.times do |i|
          ostate.fixture[:bay_index] = i
          pg = new_pdf_page(pdf, ostate)
          start_page ||= pg
          bay.to_pdf(pdf, ostate)
        end
        logger.debug "origin 2: #{ostate.origin.to_s}"
      end

    when :front_view_full # show whole fixture in a single page
      # calc scale
      start_page = new_pdf_page(pdf, ostate)
      logger.debug "scale: #{ostate.scale.to_s}"

      # draw bays of fixture
      fixture_items.each do |fi|
        logger.debug "origin 1: #{ostate.origin.to_s}"
        num_bays = fi.num_bays
        bay = fi.bay
        ostate.fixture[:fixture_item_id] = fi.id
        ostate.fixture[:num_bays] = num_bays
        bay.to_pdf(pdf, ostate)
        bay_width = bay.max_width * num_bays * ostate.scale
        logger.debug "origin 2: #{ostate.origin.to_s}"

        # draw traffic flow at bottom
        # font = 15pt
        origin = ostate.origin.dup
        pdf.bounding_box(origin, width: bay_width, height: 40) do
          pdf.text_color "#000000"
          pdf.font_size(15)
          pdf.text flow_text(), :align => :center, :valign => :center
        end

        # for next fixture item
        ostate.origin[0] += bay_width
      end
    end
    start_page
  end

  def flow_text
    flow_l2r ? "> > > > >" : "< < < < <"
  end

  # always portrait
  def make_pdf_front(pdf, bay_index)
  end

  # <UL> continuous space: layer
  #   [fixture_item:layer, bay_id:run:num_bays:space_height:shelf_height:shelf_color, ...]
  # base:
  #   [ fixture_item, bay_id:run:num_bays:base_height:base_color]
  def shelf_spaces
    spaces = {}
    fixture_items.each do |fi|
      # add base
      bay = fi.bay
      spaces[fi.id] = {
        fixture_item: fi.id,
        num_bays: fi.num_bays,
        continuous: fi.continuous,
        bay_id: bay.id,
        base_width: bay.base_width,
        base_height: bay.base_height,
        base_color: bay.base_color,
        num_layers: bay.elem_count,
        height: bay.back_height,
        width: bay.back_width,
      }

      # add each layer
      # [fixture_item:layer, bay_id:run:num_bays:space_height:shelf_height:shelf_color, ...]
      from_base = 0
      height = 0
      1.upto(bay.elem_count) do |layer|
        elem = bay.get_element(layer)
        if elem
          spaces[fi.id][layer] = {
            merch_width: elem.merch_width * fi.num_bays,
            merch_depth: elem.merch_depth,
            merch_height: elem.merch_height,
            shelf_height: elem.shelf_thick,
            from_base: elem.from_base,
            shelf_color: elem.color
          }
          if elem.from_base > from_base
            from_base = elem.from_base
            height = bay.base_height + elem.from_base + elem.shelf_thick + elem.merch_height
          end
        end
      end
      spaces[fi.id][:height] = height
    end
    return spaces
  end

  # returns layer-key => fixture_item_id, layer, merch_space
  def merch_spaces
    merch_space = Struct.new(:fixture_item, :layer, :merch_width, :merch_height, :merch_depth,
                             :used_space, :from_base, :count)
    run = {}
    spaces = []
    fixture_items.each do |fi|
      spaces.concat(fi.bay.layers.map { |layer|
        merch_space.new(fi.id, layer.level,
                        layer.merch_width * fi.num_bays, layer.merch_height, layer.merch_depth,
                        0, layer.from_base, 0) })
    end
    # convert to hash
    {}.tap { |h| spaces.each {|sp| h[Position.layer_key(sp.fixture_item, sp.layer)] = sp } }
  end

  private
  def copy_assoc_to(new_fixture, assoc_sym)
    self.send(assoc_sym).each do |row|
      new_row = row.dup # shallow copy
      new_fixture.send(assoc_sym) << new_row
    end
  end
end

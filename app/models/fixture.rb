class Fixture < ActiveRecord::Base
  default_scope -> { where('deleted_at is NULL') }
  has_many :fixture_items, -> { order(:item_index) }, dependent: :destroy
  has_many :store_fixtures, -> { order(:store_id, :category_id) }
  has_many :plans
  accepts_nested_attributes_for :fixture_items, allow_destroy: true
  accepts_nested_attributes_for :store_fixtures

  def user
    ''
  end

  def num_bays
    fixture_items.sum { |it| it.num_bays }
  end

  def run
    fixture_items.sum { |it| it.bay.run * it.num_bays }
  end

  def linear
    fixture_items.sum { |it| it.bay.linear * it.num_bays }
  end

  def area
    fixture_items.sum { |it| it.bay.area * it.num_bays }
  end

  def cube
    fixture_items.sum { |it| it.bay.cube * it.num_bays }
  end

  def ref_count
    self.ref_store.keys.size
  end

  def ref_store
    self.store_fixtures.select(:store_id).group(:store_id).count(:store_id)
  end

  def ref_plan_set
    self.plans.select(:plan_set_id).group(:plan_set_id).count(:plan_set_id).keys
  end

  def undeploy(store_fixture_id)
    self.store_fixtures.destroy(store_fixture_id)
    true
  rescue
    false
  end

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

  def version
    updated_at.to_i
  end

  def calc_size
    fixture_items.each do |fi|
      num_bays = fi.num_bays
      bay = fi.bay
    end
  end

  # new_page, set scale/origin
  def new_pdf_page(pdf)
    case pdf.ostate.fixture[:output]
    when :front_and_side_view
      # front view in upper area, small view, 1/3 height
      # side view in below area, with detailed number, 2/3 height
      pdf.ostate.origin[0] = 0.0
      pdf.ostate.origin[1] = 50.0
      pdf.ostate.scale = 0

      full_width = 0
      full_depth = 0
      full_height = 0
      count = fixture_items.size
      fixture_items.each do |fi|
        logger.debug "origin 1: #{pdf.ostate.origin.to_s}"
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
      pdf.ostate.scale = []
      pdf.ostate.origin = []

      w = bbox.right
      h = y[1]
      scale = [w / full_width, h / full_height].min
      x0 = (w - full_width * scale) / 2
      y0 = y[2] + (h - full_height * scale) / 2
      pdf.ostate.scale.push scale
      pdf.ostate.origin.push [x0, y0]

      # calculate scale/origin for bottom: side view
      h = y[3]
      extra = pdf.ostate.options[:bay_left_width] * count + pdf.ostate.options[:bay_spacing] * (count - 1)

      scale = [(w - extra)/ full_depth, h / full_height].min
      x0 = (w - extra - full_depth * scale) / 2
      y0 = (h - full_height * scale) / 2
      pdf.ostate.scale.push scale
      pdf.ostate.origin.push [x0, y0]
      logger.debug "scale: #{pdf.ostate.scale.to_s} origin: #{pdf.ostate.origin.to_s}"

    when :front_view # show fixtures, one bay per page
      bay = pdf.ostate.fixture[:_bay]
      width = bay.max_width
      height = bay.max_height
      pdf.new_page(width >= height ? :landscape : :portrait)
      bbox = pdf.bounds
      pdf.ostate.scale = scale = [bbox.right / width, bbox.top / height].min
      pdf.ostate.origin[0] = (bbox.right - width * scale) / 2
      pdf.ostate.origin[1] = (bbox.top - height * scale) / 2
      logger.debug ":front_view, origin: #{pdf.ostate.origin.to_s}, scale: #{pdf.ostate.scale}, width: #{width}, height:#{height}"

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
      pdf.ostate.scale = scale = [bbox.right / width, bbox.top / height].min

      # calculate origin
      flow_size = 30
      pdf.ostate.origin[0] = (bbox.right - width * scale) / 2
      pdf.ostate.origin[1] = (bbox.top - flow_size - height * scale) / 2
    else
      pdf.new_page
      bbox = pdf.bounds
      pdf.ostate.scale = 1.0
      pdf.ostate.origin[0] = bbox.left
      pdf.ostate.origin[1] = bbox.bottom
    end
    pdf.page_count
  end

  def to_pdf(pdf)
    logger.debug "Fixture#to_pdf, fixture:#{id} output:#{pdf.ostate.fixture[:output]}"
    start_page = nil
    case pdf.ostate.fixture[:output]
    when :merchandise
      positions = pdf.ostate.positions
      start_page = new_pdf_page(pdf)
      bbox = pdf.bounds
      pdf.move_down 20
      pdf.fill_color "000000"
      pdf.text pdf.ostate.options[:title][:mdse], :size => 20
      pdf.move_down 20
      fields = pdf.ostate.options[:mdse_fields]

      # prepare layer name for each bay
      layer_name = {}
      fixture_items.each do |fi|
        bay = fi.bay
        bay.layers.each do |layer|
          key = Position.layer_key(fi.id, layer.layer)
          # "» #{fixture.name} » 第#{layer.layer}层 » 深度: #{layer.depth}cm"
          k = self.flow_l2r ? :l2r_layer_name : :r2l_layer_name
          layer_name[key] = pdf.ostate.options[:open_shelf][k].template(
            fixture: self, bay: bay, layer: layer)
        end
      end

      pdf.font(pdf.ostate.options[:label_font]) do
        positions.each do |key, blocks|
          # logger.debug "layer_text #{key}, #{layer_name[key]} #{blocks.first.layer}"
          pdf.move_down 10
          pdf.text layer_name[key], :size => 16
          pdf.move_down 10
          tdata = [pdf.ostate.options[:mdse_fields_name]]
          tdata.concat blocks.map { |block| fields.map { |f| block.send(f) } }
          pdf.table(tdata,
            cell_style: { borders: [], },
            width: bbox.right,
            header: true) do
            style(rows(0), :borders => [:top, :bottom])
          end
        end
      end

    when :front_and_side_view
      # front view in upper area, small view
      start_page = new_pdf_page(pdf)
      scale = pdf.ostate.scale.dup
      origin = pdf.ostate.origin.dup

      pdf.ostate.scale = scale.shift
      pdf.ostate.origin = origin.shift
      pdf.ostate.fixture[:bay] = :front_view
      fixture_items.each do |fi|
        num_bays = fi.num_bays
        bay = fi.bay
        pdf.ostate.fixture[:fixture_item_id] = fi.id
        pdf.ostate.fixture[:num_bays] = num_bays
        bay.to_pdf(pdf)
        bay_width = bay.max_width * num_bays * pdf.ostate.scale

        # for next fixture item
        pdf.ostate.origin[0] += bay_width
      end

      # side view in below area, with detailed numbers
      pdf.ostate.scale = scale.shift
      pdf.ostate.origin = origin.shift
      pdf.ostate.fixture[:bay] = :side_view
      fixture_items.each do |fi|
        # logger.debug "side view bay origin: #{pdf.ostate.origin}"
        bay = fi.bay
        bay.to_pdf(pdf)
        # for next fixture item
        pdf.ostate.origin[0] += bay.max_depth * pdf.ostate.scale
      end

    when :front_view # show fixtures, one bay per page
      # draw bays of fixture
      fixture_items.each do |fi|
        logger.debug "origin 1: #{pdf.ostate.origin.to_s}"
        num_bays = fi.num_bays
        pdf.ostate.fixture[:_bay] = bay = fi.bay

        pdf.ostate.fixture[:fixture_item_id] = fi.id
        pdf.ostate.fixture[:num_bays] = 1 # one bay per page
        num_bays.times do |i|
          pdf.ostate.fixture[:bay_index] = i
          pg = new_pdf_page(pdf)
          start_page ||= pg
          bay.to_pdf(pdf)
        end
        logger.debug "origin 2: #{pdf.ostate.origin.to_s}"
      end

    when :front_view_full # show whole fixture in a single page
      # calc scale
      start_page = new_pdf_page(pdf)
      logger.debug "scale: #{pdf.ostate.scale.to_s}"

      # draw bays of fixture
      fixture_items.each do |fi|
        logger.debug "origin 1: #{pdf.ostate.origin.to_s}"
        num_bays = fi.num_bays
        bay = fi.bay
        pdf.ostate.fixture[:fixture_item_id] = fi.id
        pdf.ostate.fixture[:num_bays] = num_bays
        bay.to_pdf(pdf)
        bay_width = bay.max_width * num_bays * pdf.ostate.scale
        logger.debug "origin 2: #{pdf.ostate.origin.to_s}"

        # draw traffic flow at bottom
        # font = 15pt
        origin = pdf.ostate.origin.dup
        pdf.bounding_box(origin, width: bay_width, height: 40) do
          pdf.text_color "#000000"
          pdf.font_size(15)
          pdf.text flow_text(), :align => :center, :valign => :center
        end

        # for next fixture item
        pdf.ostate.origin[0] += bay_width
      end
    end
    logger.debug "Fixture#to_pdf completed, fixture:#{id} output:#{pdf.ostate.fixture[:output]}"
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
        num_layers: bay.num_layers,
        height: bay.back_height,
        width: bay.back_width,
      }

      # add each layer
      # [fixture_item:layer, bay_id:run:num_bays:space_height:shelf_height:shelf_color, ...]
      from_base = 0
      height = 0
      1.upto(bay.num_layers) do |layer|
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

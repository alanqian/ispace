class OpenShelf < ActiveRecord::Base
  @@template_id = 0   # TODO: load from conf
  belongs_to :bay, :class_name => Bay

  validates :name, presence: true, length: { maximum: 64 }
  validates :height, :width, :depth, :thick, presence: true,
    numericality: { greater_than_or_equal_to: 1 }
  validates :slope, :riser, presence: true,
    numericality: { greater_than_or_equal_to: 0 }

  validates :notch_num, presence: true,
    numericality: { greater_than_or_equal_to: 0 }
  validates :from_base, presence: true,
    numericality: { greater_than_or_equal_to: 0 }

  validates :color, presence: true, format: { with: %r/#[0-9a-fA-F]{1,6}/,
    message: 'color' }

  validates :from_back, presence: true,
    numericality: { greater_than_or_equal_to: 0 }
  validates :finger_space, presence: true,
    numericality: { greater_than_or_equal_to: 0 }
  validates :x_position, presence: true,
    numericality: { greater_than_or_equal_to: 0 }

  def self.template(bay)
    r = self.new(APP_CONFIG[:templates][:open_shelf])
    r.from_base = bay.notch_to(r.notch_num)
    r.bay_id = bay.id
    r.width = bay.back_width
    r.depth = bay.base_depth
    r
  end

  def position_to_pdf(pdf, block, horz)
    # calculate left/right overflow
    left_overflow = horz < 0 ? -horz : 0
    h2 = horz + block.run - width
    right_overflow = h2 < 0 ? 0 : h2
    vrun = block.run - left_overflow - right_overflow

    # draw position
    left = pdf.ostate.origin[0] + (horz + left_overflow) * pdf.ostate.scale
    w = vrun * pdf.ostate.scale
    h = block.height * block.height_units * pdf.ostate.scale
    top = pdf.ostate.fixture[:layer_space_bottom] + h

    # draw grid lines for product
    pdf.stroke_color("888888")
    pdf.line_width 0.25
    # vertical grids
    (block.width_units + 1).times do |i|
      cx = block.leading_gap + i * block.width
      if cx >= left_overflow && cx <= block.run - right_overflow # clip
        x = pdf.ostate.origin[0] + (horz + cx) * pdf.ostate.scale
        pdf.stroke_line([x, top], [x, top - h])
      end
    end
    # horizonal grids
    (block.height_units + 1).times do |i|
      y = top - i * block.height * pdf.ostate.scale
      pdf.stroke_line([left, y], [left + w, y])
    end
    pdf.line_width 1

    # draw position bounding box
    pdf.stroke_color("000000")
    pdf.fill_color(block.color)
    pdf.line_width 1.5
    gap = block.leading_gap * pdf.ostate.scale
    gap2 = (block.leading_gap + block.trail_gap) * pdf.ostate.scale
    pdf.stroke_rectangle([left + gap, top], w - gap2, h)

    # draw label
    pdf.stroke_color("000000")
    pdf.fill_color("000000")
    if vrun * 2 >= [block.run, width].min
      # show prod id/name
      text = "#{block.id} #{block.name}"
      pdf.font(pdf.ostate.options[:label_font]) do
        pdf.text_box text,
          at: [left, top],
          width: w,
          height: h,
          size: 10,
          align: :center,
          valign: :center
      end
    else
      # show <<< or >>>
      text = left_overflow > 0 ? pdf.ostate.options[:left_overflow_text] : pdf.ostate.options[:right_overflow_text]
      #logger.debug "text_box: #{text}, font:#{pdf.ostate.options[:number_font]}"
      pdf.font(pdf.ostate.options[:number_font]) do
        pdf.text_box text,
          at: [left, top],
          width: w,
          height: h,
          size: 10,
          align: :center,
          valign: :center
      end
    end
  end

  # origin=base
  def to_pdf(pdf)
    num_bays = pdf.ostate.fixture[:num_bays]
    x = pdf.ostate.origin[0]
    y1 = pdf.ostate.origin[1] + (from_base + thick + height) * pdf.ostate.scale # space top
    y2 = pdf.ostate.origin[1] + (from_base + thick) * pdf.ostate.scale # space bottom
    cx = width * pdf.ostate.scale
    case pdf.ostate.fixture[:layer]
    when :positions
      fixture_item_id = pdf.ostate.fixture[:fixture_item_id]
      key = Position.layer_key(fixture_item_id, layer)
      blocks = pdf.ostate.positions[key] || []
      bay_index = pdf.ostate.fixture[:bay_index]
      pdf.ostate.fixture[:layer_space_bottom] = y2
      pdf.stroke_color("000000")

      # find start/stop index on this bay
      left = bay_index * width
      right = (bay_index + 1) * width
      left_run = run = 0
      start = -1
      stop = blocks.size
      blocks.each_index do |i|
        if start < 0 && run + blocks[i].run > left
          start = i
          left_run = run
        end
        if start >= 0 && run >= right
          stop = i
          break
        end
        run += blocks[i].run
      end

      # draw each positions
      #logger.debug "draw positions, width:#{width} start:#{start} stop:#{stop} left_run:#{left_run} left:#{left}"
      horz = left_run - left
      for i in start..(stop - 1)
        # draw full position
        block = blocks[i]
        position_to_pdf(pdf, block, horz)
        horz += block.run
      end
      #logger.debug "horz: #{left_run-left}, #{horz}"

    when :blocks
      fixture_item_id = pdf.ostate.fixture[:fixture_item_id]
      key = Position.layer_key(fixture_item_id, layer)
      blocks = pdf.ostate.blocks[key] || []
      pdf.stroke_color("000000")
      horz = 0
      blocks.each do |group|
        x = pdf.ostate.origin[0] + horz * pdf.ostate.scale
        hprev = 0
        cx = 0
        pts = []
        group.each do |block|
          y = y2 + block.height * pdf.ostate.scale
          if (hprev - block.height).abs > 0.1
            pts.push [x + cx * pdf.ostate.scale, y]   # left,top
            hprev = block.height
          end
          cx += block.width
          pts.push [x + cx * pdf.ostate.scale, y]   # right,top
        end

        # modify x of 1st/last block
        first = group.first
        x1 = pdf.ostate.origin[0] + (horz + first.leading_gap) * pdf.ostate.scale
        x2 = pdf.ostate.origin[0] + (horz + cx - group.last.trail_gap) * pdf.ostate.scale
        pts.first[0] = x1
        pts.last[0] = x2

        pts.push [x2, y2]  # right,bottom of last
        pts.push [x1, y2]  # left,bottom of first block

        pdf.stroke_polygon(*pts)
        pdf.fill_color(first.color)
        pdf.fill_polygon(*pts)

        # draw block label
        pdf.text_color "000000"
        pdf.font(pdf.ostate.options[:label_font]) do
          pdf.text_box first.name,
            :at => [x1, y1], :width => x2 - x1, :height => y1 - y2,
            :align => :center, :valign => :center, :size => 9
        end

        # next group
        horz += cx
      end

    when :front_view
      pdf.fill_color(color)
      num_bays.times do
        # draw space without fill
        pdf.stroke_rectangle([x, y1], cx, height * pdf.ostate.scale)
        # draw shelf with fill
        pdf.fill_and_stroke_rectangle([x, y2], cx, thick * pdf.ostate.scale)
        x += cx
      end

    when :side_view
      pdf.fill_color(color)
      # draw shelf only, with fill
      cx = depth * pdf.ostate.scale
      pdf.fill_and_stroke_rectangle([x, y2], cx, thick * pdf.ostate.scale)
      size_text = "#{depth}cm"
      pdf.draw_horz_distance(size_text,
                             at: [x, y2], width: cx,
                             above: pdf.ostate.options[:distance_above],
                             scale_size: pdf.ostate.options[:scale_size],
                             scale_font_size: pdf.ostate.options[:scale_font_size])
      size_text = "#{height}cm"
      h = height * pdf.ostate.scale
      pdf.draw_vert_distance(size_text,
                             at: [pdf.ostate.fixture[:back_left], y2 + h], height: h,
                             left: pdf.ostate.options[:distance_left],
                             scale_size: pdf.ostate.options[:scale_size],
                             scale_font_size: pdf.ostate.options[:scale_font_size])

    when :text
      # write text on shelf
      #text = "第#{level}层, 深度: #{depth}mm"
      cx *= num_bays
      text = pdf.ostate.options[:open_shelf][:shelf_text].template(level: level, depth: depth)
      size = 100
      pt = 8
      pdf.fill_color("#000000")
      pdf.text_box text,
        at: [x + cx / 2 - size / 2, y2],
        width: size,
        height: self.thick * pdf.ostate.scale,
        size: pt,
        align: :center,
        valign: :center
    end
  end

  alias_attribute :merch_depth, :depth
  alias_attribute :merch_width, :width
  alias_attribute :merch_height, :height
  alias_attribute :shelf_thick, :thick
  alias_attribute :layer, :level
end

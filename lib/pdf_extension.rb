module PdfExtension
  class OutputState < Struct.new(:origin, :scale, :options, :fixture, :blocks,
                                 :positions, :outline)
    def initialize(hash)
      super(*hash.values_at(:origin, :scale, :options, :fixture, :blocks,
                            :positions))
      self.outline = {}
    end
  end

end

module PrawnExtension
  # TODO: borrow from prawn master branch, will deleted when prawn released it!
  def stroke_axis(options = {})
    options = {
      :at => [0,0],
      :height => bounds.height.to_i - (options[:at] || [0,0])[1],
      :width => bounds.width.to_i - (options[:at] || [0,0])[0],
      :step_length => 100,
      :negative_axes_length => 20,
      :color => "000000",
    }.merge(options)

    Prawn.verify_options([:at, :width, :height, :step_length,
                         :negative_axes_length, :color], options)

    save_graphics_state do
      fill_color(options[:color])
      stroke_color(options[:color])

      dash(1, :space => 4)
      stroke_horizontal_line(options[:at][0] - options[:negative_axes_length],
                             options[:at][0] + options[:width], :at => options[:at][1])
      stroke_vertical_line(options[:at][1] - options[:negative_axes_length],
                           options[:at][1] + options[:height], :at => options[:at][0])
      undash

      fill_circle(options[:at], 1)

      (options[:step_length]..options[:width]).step(options[:step_length]) do |point|
        fill_circle([options[:at][0] + point, options[:at][1]], 1)
        draw_text(point, :at => [options[:at][0] + point - 5, options[:at][1] - 10], :size => 7)
      end

      (options[:step_length]..options[:height]).step(options[:step_length]) do |point|
        fill_circle([options[:at][0], options[:at][1] + point], 1)
        draw_text(point, :at => [options[:at][0] - 17, options[:at][1] + point - 2], :size => 7)
      end
    end
  end

  def color(color)
    color.sub('#', '')
  end

  def text_color(color)
    fill_color(color)
  end

  def fill_color(color="000000")
    super (color || "FFFFFF").sub('#', '')
  end

  def draw_horz_distance(text, opt)
    at = opt[:at]
    width = opt[:width]
    above = opt[:above]
    scale_size = opt[:scale_size]
    scale_font_size = opt[:scale_font_size]

    # draw vert lines at both side
    x = [at[0], at[0] + width]
    y = [at[1] + above + scale_size / 2, at[1] + above - scale_size / 2]
    self.stroke_line [x[0], y[0]], [x[0], y[1]]
    self.stroke_line [x[1], y[0]], [x[1], y[1]]

    # draw horz arrow line
    y0 = at[1] + above
    text_width = self.width_of(text, size: scale_font_size) + 6
    remain = (width - text_width) / 2
    self.stroke_line [x[0], y0], [x[0] + remain, y0]
    self.stroke_line [x[1] - remain, y0], [x[1], y0]

    # draw scale text
    self.stroke_color("000000")
    self.fill_color("000000")
    self.text_box text,
      at: [x[0], y[0] + (scale_font_size * 1.2 - scale_size) / 2],
      width: width,
      height: scale_size,
      size: scale_font_size,
      align: :center,
      valign: :center
    self.text_box "<",
      at: [x[0], y[0] + (scale_font_size - scale_size) / 2],
      width: width,
      height: scale_size,
      size: scale_font_size,
      align: :left,
      valign: :center
    self.text_box ">",
      at: [x[0], y[0] + (scale_font_size - scale_size) / 2],
      width: width,
      height: scale_size,
      size: scale_font_size,
      align: :right,
      valign: :center
  end

  def draw_vert_distance(text, opt)
    at = opt[:at]
    height = opt[:height]
    left = opt[:left]
    scale_size = opt[:scale_size]
    scale_font_size = opt[:scale_font_size]

    # draw horz lines at both side
    x = [at[0] - left - scale_size / 2, at[0] - left + scale_size / 2]
    y = [at[1] - height, at[1]]
    self.stroke_line [x[0], y[0]], [x[1], y[0]]
    self.stroke_line [x[0], y[1]], [x[1], y[1]]

    # draw vert arrow line
    x0 = at[0] - left
    text_width = self.width_of(text, size: scale_font_size) + 6
    remain = (height - scale_font_size * 1.2) / 2
    self.stroke_line [x0, y[0]], [x0, y[0] + remain]
    self.stroke_line [x0, y[1] - remain], [x0, y[1]]

    # draw text
    self.stroke_color("000000")
    self.fill_color("000000")
    self.text_box text,
      at: [x[1] - text_width, y[1]],
      width: text_width,
      height: y[1] - y[0],
      size: scale_font_size,
      align: :right,
      valign: :center
    self.text_box "<",
      at: [x[1] - scale_font_size * 0.25, y[1]],
      width: height,
      height: scale_size,
      size: scale_font_size,
      align: :left,
      valign: :center,
      rotate: 270,
      rotate_around: :upper_left
    self.text_box ">",
      at: [x[1] - scale_font_size * 0.25, y[1]],
      width: height,
      height: scale_size,
      size: scale_font_size,
      align: :right,
      valign: :center,
      rotate: 270,
      rotate_around: :upper_left
  end

  def new_page(page_layout = :portrait)
    self.start_new_page(layout: page_layout)
    # stroke_axis
  end

  def header
  end

  def footer
  end

  def register_fonts(opt)
    @@system_paths ||= {
      '#{Prawn::BASEDIR}' => Prawn::BASEDIR,
      '#{Rails.root}' => Rails.root.to_s,
    }
    families = opt[:font_families]
    families.each do |f, fonts|
      fonts.each do |style, file|
        families[f][style] = file.sub(/^\#\{(Prawn::BASEDIR|Rails\.root)\}/) do |s|
          @@system_paths[s]
        end
      end
    end
    Rails.logger.debug "register_fonts: #{families.to_json}"
    font_families.update(families)
    fallback_fonts opt[:fallbacks]
  end

  attr_accessor :ostate
end

Prawn::Document.send(:include, PrawnExtension)


root = exports ? this

Raphael.fn.harrow = (x1, y1, x2, arrow_size) ->
  # P1, P2, P3, P4, P2
  x3 = x4 = if x2 > x1 then x2 - arrow_size * 3.5 else x2 + arrow_size * 3.5
  y3 = y1 - arrow_size
  y4 = y1 + arrow_size
  @path "M#{x1} #{y1} L#{x2} #{y1} L#{x3} #{y3} L#{x4} #{y4} L#{x2} #{y1}"

Raphael.fn.line = (x1, y1, x2, y2) ->
  @path "M#{x1} #{y1} L#{x2} #{y2}"

Raphael.fn.triangle = (x1, y1, x2, y2, x3, y3) ->
  @path "M#{x1} #{y1} L#{x2} #{y2} L#{x3} #{y3} L#{x1} #{y1}"

Raphael.fn.hruler = (x1, y1, x2, size, cy, text) ->
  x0 = (x1 + x2) / 2 # middle point
  results = []
  results.push @harrow(x0 - size / 2, y1, x1, 3)
  results.push @harrow(x0 + size / 2, y1, x2, 3)
  results.push @path("M#{x1} #{y1 - cy / 2} L#{x1} #{y1 + cy / 2} " +
    "M#{x2} #{y1 - cy / 2} L#{x2} #{y1 + cy / 2}")
  results.push @text(x0, y1, text)
  results

Raphael.el.affine = (trans) ->
  @transform "m#{trans.scale},0,0,#{trans.scale},#{trans.x0},#{trans.y0}"

root.Bay = class Bay
  bay: {}
  width: 0
  height: 0
  ostate: {}
  spacing: 50          # spacing between front view and side view
  back_ruler_width: 10
  margin: [20, 2, 20, 2] # top, right, bottom, left
  focusName: null
  fontSize: 10

  constructor: (formData, focusName) ->
    @bay = formData.bay
    @bay.open_shelves ||= []
    @bay.use_notch ||= false
    @focus_name = focusName

  draw: (paper, cx, cy) ->
    return false unless @bay.hasOwnProperty("name")

    # draw bounding boxes
    paper.clear()
    paper.rect(0, 1, cx, cy-1)
    @calcLayout(paper, cx, cy)
    console.log "ostate:", @ostate

    scale = @ostate.scale
    #paper.rect(0, 0, @ostate.frontview.width, @ostate.frontview.height)
    #  .transform "s#{scale}t#{@ostate.frontview.x0},#{@ostate.frontview.y0}"

    # draw guide box
    #paper.rect(@ostate.frontview.x0, @ostate.frontview.y0, @ostate.frontview.width * scale,
    #  @ostate.frontview.height * scale).attr("stroke", "red")
    #paper.rect(@ostate.sideview.x0, @ostate.sideview.y0, @ostate.sideview.width * scale,
    #  @ostate.sideview.height * scale).attr("stroke", "red")

    @drawFront(paper)
    @drawSide(paper)
    @drawBackRuler(paper)
    @drawTakeoffHeight(paper)
    @drawTest(paper)
    return paper

  calcLayout: (paper, cx, cy) ->
    # front view at left, side view at right
    cx -= @spacing + @margin[1] + @margin[3]
    cy -= @margin[2] + @margin[0]

    height = @bay.back_height + @bay.base_height
    depths = @bay.open_shelves.map (x) -> x.depth
    max_depth = depths.reduce ((x, y) -> Math.max(x, y)), 0
    widths = @bay.open_shelves.map (x) -> x.width
    max_width = widths.reduce ((x, y) -> Math.max(x, y)), 0
    heights = @bay.open_shelves.map (x) -> x.height + x.from_base
    @bay.takeoff_height = @bay.base_height + heights.reduce ((x, y) -> Math.max(x, y)), 0
    console.log max_depth, max_width, @bay.takeoff_height

    sideview_width = Math.max @bay.base_depth, @bay.back_thick + (max_depth || 0)
    frontview_width = Math.max @bay.back_width, (max_width || 0)

    width = sideview_width + frontview_width

    scale = Math.min(cx / width, cy / height)
    offset =
      x: (cx - scale * width) / 2
      y: (cy - scale * height) / 2

    @ostate.width = width * scale + @spacing
    @ostate.height = height * scale
    @ostate.scale = scale
    @ostate.frontview =
      scale: scale
      x0: @margin[3] + offset.x
      y0: @margin[0]
      width: frontview_width
      height: @bay.back_height
    #paper.rect(@ostate.frontview.x0, @ostate.frontview.y0, frontview_width * scale,
    #  height * scale)
    @ostate.sideview =
      scale: scale
      x0: @ostate.frontview.x0 + frontview_width * scale + @spacing
      y0: @margin[0]
      width: sideview_width
      height: @bay.back_height

    return true

  drawTest: (paper) ->
    return true
    # test raphael.js transform, it's better to use
    console.log "yellow: sideviewRect; bule: t, red: m, scale:", @ostate.scale
    console.log "sideview:", @ostate.sideview
    if false
      # no transform
      paper.rect(0, 0, @ostate.sideview.width, @ostate.sideview.height)
        .attr("stroke", "yellow")
      # transform t
      paper.rect(0, 0, @ostate.sideview.width, @ostate.sideview.height)
        .transform("t#{@ostate.sideview.x0},#{@ostate.sideview.y0}")
        .attr("stroke", "blue")
    #---------------------------------------------------------------------
    # transform m, test passed
    paper.rect(0, 0, @ostate.sideview.width, @ostate.sideview.height)
      .transform("m#{@ostate.scale},0,0,#{@ostate.scale},#{@ostate.sideview.x0},#{@ostate.sideview.y0}")
      .attr("stroke", "red")

    #---------------------------------------------------------------------
    # test draw side part: back part use transform
    paper.rect(0, 0, @bay.base_depth, @bay.back_height)
      .transform("m#{@ostate.scale},0,0,#{@ostate.scale},#{@ostate.sideview.x0},#{@ostate.sideview.y0}")
      .attr("stroke", "green")
    # test draw a slope line
    paper.path("M#{@bay.back_thick * 2} #{@bay.back_height / 2} L#{0} #{@bay.back_height}")
      .transform("m#{@ostate.scale},0,0,#{@ostate.scale},#{@ostate.sideview.x0},#{@ostate.sideview.y0}")
      .attr("stroke", "red")
    paper.text(0, 0, "test text")
      .attr("font-size", 40)
      .transform("m#{@ostate.scale},0,0,#{@ostate.scale},#{@ostate.sideview.x0},#{@ostate.sideview.y0}")
      .attr("fill", "red")
    paper.text(@ostate.sideview.x0, @ostate.sideview.y0 + 60, "test text 2")
      .attr("font-size", 40)
      .attr("fill", "red")
    #---------------------------------------------------------------------
    # test draw front part
    cx = @bay.base_width
    cy = @bay.back_height
    t = paper.rect(0, 0, cx, cy)
      .transform("m#{@ostate.scale},0,0,#{@ostate.scale},#{@ostate.frontview.x0},#{@ostate.frontview.y0}")
      .attr("stroke", "green")
    console.log t

    # test draw use affine
    t = paper.rect(0, cy / 3, cx / 2, cy / 3)
      .affine(@ostate.frontview)
      .attr("fill", "green")
      .attr("stroke", "red")

    #---------------------------------------------------------------------
    self = @
    paper.line(0, 0, cx, 10)
      .affine(self.ostate.frontview)
      .attr("stroke", "red")
    paper.triangle(0, 0, cx, 10, cx, 40)
      .affine(self.ostate.frontview)
      .attr("stroke", "red")

    paper.harrow(50, 50, cx, 6)
      .affine(self.ostate.frontview)
      .attr("fill", "red")
      .attr("stroke", "red")

    return true

  drawSide: (paper, x0, y0, cx, cy) ->
    # draw base, filled with color
    paper.rect(0, @bay.back_height, @bay.base_depth, @bay.base_height)
      .affine(@ostate.sideview)
      .attr("fill", @bay.base_color)
    # draw back
    paper.rect(0, 0, @bay.back_thick, @bay.back_height)
      .affine(@ostate.sideview)
      .attr("fill", @bay.back_color)

    # draw shelves & numbers, filled with color
    self = @
    for shelf in @bay.open_shelves
      if shelf # to avoid sparse array by adding new element
        @render.open_shelf.drawSide.call(self, paper, shelf)
      true
    return true

  render:
    open_shelf:
      drawFront: (paper, shelf) ->
        y = @bay.back_height - shelf.from_base
        # draw merchandise space
        paper.rect(0, y - shelf.height, shelf.width, shelf.height)
          .affine(@ostate.frontview)
          .attr("stroke-dasharray", "- ")
          .attr("stroke", "darkgray")
          .attr("fill", "#eeeeee")
        # draw shelf
        paper.rect(0, y, shelf.width, shelf.thick)
          .affine(@ostate.frontview)
          .attr("fill", shelf.color)
        # draw shelf text
        paper.text(shelf.width / 2, y + shelf.thick / 2, "#{shelf.name} #{shelf.width}mm")
          .attr("font-size", @fontSize / @ostate.scale)
          .affine(@ostate.frontview)
        return true

      drawSide: (paper, shelf) ->
        x = @bay.back_thick
        y = @bay.back_height - shelf.from_base

        # draw shelf
        paper.rect(@bay.back_thick, y, shelf.depth, shelf.thick)
          .affine(@ostate.sideview)
          .attr("fill", shelf.color)

        cx = shelf.depth
        cy = 20 / @ostate.scale
        x0 = cx / 2
        #paper.text(x0, y + cy / 2, shelf.name)
        # draw depth metrics
        y0 = y - cy / 2
        self = @
        paper.hruler(x, y0, x + cx, 40, 20, "#{shelf.depth}mm").forEach (el) ->
          el.affine(self.ostate.sideview)
            .attr("fill", "black")
        return true

  drawTakeoffHeight: (paper) ->
    scale = @ostate.scale
    x1 = @ostate.frontview.x0
    x2 = x1 + @ostate.width
    y0 = @ostate.sideview.y0
    y = y0 + (@bay.back_height - @bay.takeoff_height + @bay.base_height) * scale
    paper.path("M#{x1} #{y} L#{x2} #{y}")
      .attr("stroke-dasharray", "- ")
      .attr("stroke", "blue")
    paper.text(x2, y - @fontSize, "#{@bay.takeoff_height}mm")
      .attr("text-anchor", "end")
      .attr("fill", "blue")

  drawBackRuler: (paper) ->
    # |x2 |x1 |x0
    x0 = -2.0 / @ostate.scale
    cx = @back_ruler_width / @ostate.scale
    x1 = x0 - cx / 2
    x2 = x0 - cx
    fontSize = @fontSize / @ostate.scale

    # draw notch ruler at the left side to sideview
    if @bay.use_notch
      y0 = @bay.back_height - @bay.notch_1st  # notch #1
      y0 += @bay.notch_spacing                # notch #0
      for y in [y0..0] by -2 * @bay.notch_spacing
        h = (y0 - y) / @bay.notch_spacing
        if (h % 10) == 0
          paper.line(x2, y, x0, y).affine(@ostate.sideview)
          paper.text(x2 + x0, y, "#{h}")
            .attr("text-anchor", "end")
            .attr("font-size", fontSize)
            .affine(@ostate.sideview)
        else
          paper.line(x1, y, x0, y).affine(@ostate.sideview)
    else
      # draw height from floor
      y0 = @bay.back_height + @bay.base_height
      for y in [y0..0] by -20
        h = y0 - y
        if (h % 100) == 0
          paper.line(x2, y, x0, y).affine(@ostate.sideview)
          paper.text(x2 + x0, y, "#{h/10}")
            .attr("text-anchor", "end")
            .attr("font-size", fontSize)
            .affine(@ostate.sideview)
        else
          paper.line(x1, y, x0, y).affine(@ostate.sideview)
    return true

  drawFront: (paper, x0, y0, cx, cy) ->
    # draw back with fill color
    paper.rect(0, 0, @bay.back_width, @bay.back_height)
      .attr("fill", @bay.back_color)

    # draw base with fill color
    paper.rect(0, @bay.back_height, @bay.base_width, @bay.base_height)
      .affine(@ostate.frontview)
      .attr("fill", @bay.base_color)

    self = @
    for shelf in @bay.open_shelves
      if shelf # to avoid sparse array by adding new element
        @render.open_shelf.drawFront.call(self, paper, shelf)
      true
    return true


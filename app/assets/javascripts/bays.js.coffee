# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

root = exports ? this

root.test = () ->
  data = input2json("bay", "form :input:not([type='submit'])")
  return data

String::chopPrefix = (prefix) ->
  len = prefix.length
  if this.substr(0, len) == prefix
    return this.substr(len, this.length)
  else
    return ""

input2json = (obName, selector) ->
  data =
    _re: new RegExp("\\[([\\w\\d\_]+)\\]", "g")
    eval: (inputName) ->
      val = this
      while m = this._re.exec(inputName)
        field = m[1].replace("_attributes", "") # m[1] -> $1, ...
        field = parseInt(field) if field.match /^\d+$/
        val = val[field]
      return val
  data[obName] = {}

  removed = {}
  $(selector).each (index, el) ->
    name = el.name.chopPrefix(obName)
    return true unless name != ""

    fields = []
    while m = data._re.exec(name)
      field = m[1].replace("_attributes", "") # m[1] -> $1, ...
      field = parseInt(field) if field.match /^\d+$/
      fields.push field
    tail = fields.pop()
    key = fields.join(".")
    return true if removed[key]?

    # normalize value
    if $(el).hasClass("decimal")
      val = parseFloat($(el).val()) || 0
    else if $(el).hasClass("integer")
      val = parseInt($(el).val()) || 0
    else if $(el).hasClass("color")
      val = $(el).val() || "#eeeeee"
    else if $(el).hasClass("string")
      val = $(el).val() || ""
    else if $(el).attr("type") == "checkbox"
      val = $(el).is(":checked") || false
    else if $(el).attr("type") == "hidden"
      val = $(el).val() || 0
    else
      console.log "unknown input: ", el
      val = $(el).val() || 0

    #console.log key, tail, val
    if tail == "_destroy"
      if val == "1"  # hidden
        # remove the whole parent branch
        removed[key] = val
        tail = fields.pop()
        v = data[obName]
        for field in fields
          if v[field]?
            v = v[field]
          else
            return true
        delete v.splice(tail, 1)
    else
      # initialize the section value to [] if undefined
      v = data[obName]
      for field in fields
        unless v[field]?
          if typeof(field) == "number"
            v[field] = {}
          else
            v[field] = []
        v = v[field]
      # set node value
      v[tail] = val
    return true

  # console.log removed
  return data

# take_off_height = base_height + MAX(from_base + height)
# for open_shelf:
#   next.from_base = this.from_base + this.height + this.finger_space + next.thick
#   notch_num/from_base: above the shelf board;
# for peg_board:
#   notch_num/from_base: top margin of the pegboard to base
# for rsb:
#   notch_num/from_base: top margin of bar
# for freezer_chest:
#   notch_num/from_base: NA
root.BayPage = class BayPage
  action: ""
  _do: ""
  bay: null
  focus: null

  constructor: (action, _do) ->
    console.log "create BayPage"
    @action = action
    @_do = _do

  onLoadIndex: () ->
    # do nothing

  onLoadEdit: () ->
    @loadBayEditor()

    # @updateSlide()
  # TODO: add slide to adjust shelf notch_num
  #<div>
  #  <label for="amount">Target sales goal (Millions):</label>
  #  <input type="text" id="amount" style="border:0; color:#f6931f; font-weight:bold;">
  #</div>
  #<div id="slider-range" style="display:block;height:250px;"></div>
  updateSlide: () ->
    $("#slider-range").slider
      orientation: "vertical"
      range: "min"
      min: 0
      max: 100
      value: 60
      slide: (event, ui) ->
        $("#amount").val $("#slider-range").slider("value")
    handler = $("<a href='#' id='set-active-shelf' data-id=1></a>").addClass('ui-slider-handle ui-state-default ui-corner-all cmd_ui')
    handler.css("bottom", "10%").appendTo $("#slider-range")
    $.util.init("cmd-ui:anchor", "#slider-range")

  onLoadNew: () ->
    @loadBayEditor()

  onBaySave: (el) ->
    form = $(el).closest("form")
    form.submit()
    return true

  onAddOpenShelf: (el) ->
    @addElement('#open_shelf')
    return true

  onAddPegBoard: (el) ->
    @addElement('#peg_board')
    return true

  onAddFreezerChest: (el) ->
    @addElement('#freezer_chest', true)
    $("#accordion").accordion "option", "active", $("#accordion h3").length - 1
    return true

  onAddRearSupportBar: () ->
    @addElement('#rear_support_bar')
    return true

  onRemoveElement: (el) ->
    console.log "removeElement"
    # set _destroy to true
    $(el).siblings("input[type=hidden][name$='[_destroy]']").val("1")
    # move the elements h3+div to dummy
    h3 = $(el).closest("h3")
    rIndex = $("#accordion").children("h3").index(h3)
    active = $("#accordion").accordion( "option", "active")
    active -= 1 if rIndex <= active && active > 0
    # console.log "index: ", rIndex, "active: ", active
    h3.next().andSelf().appendTo($("#dummy"))
    $("#accordion").accordion("option", "active", -1)
    $("#accordion").accordion("refresh")
    return true

  addElement: (dataId, bottomOne = false) ->
    if bottomOne && $("#accordion .bottom_only").length
      alert "嗨，这个东东放一个就够了，在最下层"
      console.log "**** chest exists ****"
      return

    console.log "current active element:",
      $("#accordion").accordion("option", "active")
    console.log "data-id:", dataId
    console.log "maxElems:", @bay.maxElems
    tmpl = $(dataId)

    re = new RegExp(tmpl.data("id"), "g")
    fieldId = (@bay.newIndex + 33330).toString()
    console.log re
    console.log "fieldId:", fieldId
    src = $(tmpl).html().replace("\\n", "").replace(re, fieldId)
    # console.log src
    if bottomOne
      $new = $(src).appendTo("#accordion")
    else
      $new = $(src).prependTo("#accordion")
    $("#accordion").accordion("destroy").accordion
      collapsible: true
      heightStyle: "content"

    $.util.init("cmd-ui:anchor", $new) # for remove anchor
    @initFormElement()

    # assume first input is element name
    nameElem = $("input", $new).first()
    level = if bottomOne then 1 else $("#accordion h3").length
    if nameElem
      new_name = "#{level}.#{nameElem.attr("placeholder")}"
      nameElem.val(new_name)

    @bay.newIndex += 1
    return true

  updateElementsLevel: () ->
    elems = $("#accordion h3")
    level = elems.length
    # levels is top-down, desc
    elems.each (index, h3) ->
      input = $("input[type=hidden][name$='[level]']", h3)
      console.log h3, input
      input.val(level)
      level--
      true

  updateNotchInputView: (use_notch) ->
    if use_notch
      @bay.to_notches()
      $("input[name$='[notch_num]']").parent().show()
      $("input[name$='[from_base]']").parent().hide()
      $("input[name$='[from_base]']").removeAttr("required")
      $("#bay_notch_1st, #bay_notch_spacing").prop("disabled", false)
      $("#bay_notch_1st, #bay_notch_spacing").prev().fadeTo(10, 1)
    else
      @bay.notches_to()
      $("input[name$='[from_base]']").parent().show()
      $("input[name$='[notch_num]']").parent().hide()
      $("input[name$='[notch_num]']").removeAttr("required")
      $("#bay_notch_1st, #bay_notch_spacing").prop("disabled", true)
      $("#bay_notch_1st, #bay_notch_spacing").prev().fadeTo(10, 0.5)

  initFormElement: (container = "form.simple_form.bay") ->
    self = @
    $("select.colorpicker", container).simplecolorpicker
      picker: true
    $(":input", container).focus () ->
      self.focus = this.name
      self.updatePreview(this.name)

    $(":input", container).change () ->
      self.focus = this.name
      self.updatePreview(this.name)

  loadBayEditor: () ->
    console.log "bay editor start loading..."
    @patchRaphael()

    sortByChildElem = (a, b) ->
      va = parseFloat($(a).find(".elem_sort_by")[0].value) || 0.0
      vb = parseFloat($(b).find(".elem_sort_by")[0].value) || 0.0
      # console.log "sort:", va, vb
      return vb - va
    $("div .elem_inputs").sort(sortByChildElem).children().appendTo("#accordion")

    $("div .elem_inputs").animate({ marginLeft: 10 }, "fast")
    $("div .elem_inputs").css({"background-color":"#88ff88"})
    $("#accordion").accordion
      active: -1
      heightStyle: "content"
      collapsible: true

    count = $("div .elem_inputs").length
    @bay =
      newIndex: count + 1
      active: count - 1
      use_notch: -> $("#bay_use_notch").is(":checked")
      notch_spacing: -> parseFloat $("#bay_notch_spacing").val()
      notch_1st: -> parseFloat $("#bay_notch_1st").val()
      notches_to: () ->
        notch_spacing = @notch_spacing()
        notch_1st = @notch_1st()
        return if notch_spacing < 0.5 || notch_1st < 0.5

        notch_nums = $("#accordion input[name$='[notch_num]']").map () -> parseInt $(this).val()
        # console.log "notches_to: ", notch_nums.get()
        $("#accordion input[name$='[from_base]']").each (i, el) =>
          $(el).val (notch_nums.get(i) - 1) * notch_spacing + notch_1st
        # console.log "end of notches_to"

      to_notches: () ->
        notch_spacing = @notch_spacing()
        notch_1st = @notch_1st()
        return if notch_spacing < 0.5 || notch_1st < 0.5

        from_bases = $("#accordion input[name$='[from_base]']").map () -> parseFloat $(this).val()
        # console.log "to_notches: ", from_bases.get()
        $("#accordion input[name$='[notch_num]']").each (i, el) =>
          $(el).val Math.floor((from_bases.get(i) - notch_1st) / notch_spacing) + 1
        # console.log "end of to_notches"


    @updateNotchInputView $("#bay_use_notch").is(":checked")

    # move template outside of the form
    $("form").after($("#template"))

    # install notch based handler: change(), submit()
    self = @
    $("#bay_use_notch").change (ev) ->
      console.log "use notch changed!", $(this).is(":checked")
      self.updateNotchInputView $(this).is(":checked")

    $("form.simple_form.bay").submit () ->
      self.normalizeFormInputs()
      return true

    @initFormElement()

    # page loaded
    @initPreview()
    @updatePreview()
    return true

  # notch, level
  normalizeFormInputs: () ->
    console.log "update notch_num/from_base, use_notch:", $("#bay_use_notch").is(":checked")
    if $("#bay_use_notch").is(":checked")
      # update from_base
      @bay.notches_to()
    else
      # always let browser send notch_* parameter, and update notch_num as well
      $("#bay_notch_1st, #bay_notch_spacing").prop("disabled", false)
      @bay.to_notches()
    @updateElementsLevel()
    # TODO: check notch_nums and from_base of each level
    return true

  initPreview: () ->
    preview = $("#bay-preview")
    preview.height(preview.parent().height() - 5)
    console.log preview

  updatePreview: (inputName) ->
    @normalizeFormInputs()
    data = input2json("bay", "form :input:not([type='submit'])")
    bay = new Bay(data, inputName)
    console.log bay
    preview = $("#bay-preview")
    cx = preview.width()
    cy = preview.height()
    paper = Raphael(preview[0], cx, cy)
    bay.draw(paper, cx, cy)
    true

  patchRaphael: () ->
    Raphael.fn.arrow = (x1, y1, x2, y2, size) ->
      angle = Math.atan2(x1 - x2, y2 - y1)
      angle = (angle / (2 * Math.PI)) * 360
      arrowPath = this.path("M" + x2 + " " + y2 + " L" + (x2 - size) + " " +
        (y2 - size) + " L" + (x2 - size) + " " + (y2 + size) + " L" + x2 +
        " " + y2 ).attr("fill","black").rotate((90 + angle), x2, y2)
      linePath = this.path("M" + x1 + " " + y1 + " L" + x2 + " " + y2)
      return [linePath,arrowPath]

    Raphael.fn.hruler = (x1, y1, x2, size, cy, text) ->
      x0 = (x1 + x2) / 2 # middle point
      results = this.arrow(x0 - size / 2, y1, x1, y1, 3)
      results.concat this.arrow(x0 + size / 2, y1, x2, y1, 3)
      results.push this.path("M#{x1} #{y1 - cy / 2} L#{x1} #{y1 + cy / 2} " +
        "M#{x2} #{y1 - cy / 2} L#{x2} #{y1 + cy / 2}")
      results.push this.text(x0, y1, text)
      results

class Bay
  bay: {}
  width: 0
  height: 0
  ostate: {}
  spacing: 50          # spacing between front view and side view
  notch_ruler_width: 10
  margin: [20, 2, 20, 2] # top, right, bottom, left
  focusName: null

  constructor: (data, focusName) ->
    @bay = data.bay
    @focus_name = focusName

  draw: (paper, cx, cy) ->
    return false unless @bay.hasOwnProperty("name")

    # draw bounding boxes
    paper.clear()
    paper.rect(0, 1, cx, cy-1)
    @calcLayout(paper, cx, cy)
    console.log "ostate:", @ostate

    scale = @ostate.scale
    #paper.rect(0, 0, @ostate.frontview.width, @ostate.frontview.height).
    #  transform "s#{scale}t#{@ostate.frontview.x0},#{@ostate.frontview.y0}"

    # draw guide box
    #paper.rect(@ostate.frontview.x0, @ostate.frontview.y0, @ostate.frontview.width * scale,
    #  @ostate.frontview.height * scale).attr("stroke", "red")
    #paper.rect(@ostate.sideview.x0, @ostate.sideview.y0, @ostate.sideview.width * scale,
    #  @ostate.sideview.height * scale).attr("stroke", "red")

    @drawFront(paper)
    @drawSide(paper)
    @drawNotchNums(paper)
    @drawTakeoffHeight(paper)
    return paper

  calcLayout: (paper, cx, cy) ->
    # front view at left, side view at right
    cx -= @spacing + @margin[1] + @margin[3]
    cy -= @margin[2] + @margin[0]

    height = @bay.back_height + @bay.base_height
    depths = @bay.open_shelves.map (x) -> x.depth
    max_depth = depths.reduce (x, y) -> Math.max(x, y)
    widths = @bay.open_shelves.map (x) -> x.width
    max_width = widths.reduce (x, y) -> Math.max(x, y)
    heights = @bay.open_shelves.map (x) -> x.height + x.from_base
    @bay.takeoff_height = heights.reduce (x, y) -> Math.max(x, y)
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
      x0: @margin[3] + offset.x
      y0: @margin[0]
      width: frontview_width
      height: @bay.back_height
    #paper.rect(@ostate.frontview.x0, @ostate.frontview.y0, frontview_width * scale,
    #  height * scale)
    @ostate.sideview =
      x0: @ostate.frontview.x0 + frontview_width * scale + @spacing
      y0: @margin[0]
      width: sideview_width
      height: @bay.back_height
    return true

    paper.rect(0, 0, @ostate.sideview.width, @ostate.sideview.height).
      attr("stroke", "yellow")
    paper.rect(0, 0, @ostate.sideview.width, @ostate.sideview.height).
      transform("s#{@ostate.scale}").
      attr("stroke", "blue")
    paper.rect(0, 0, @ostate.sideview.width, @ostate.sideview.height).
      transform("t#{@ostate.sideview.x0},#{@ostate.sideview.y0}").
      attr("stroke", "black")
    console.log "front: ", frontview_width * scale, "side: ", sideview_width * scale,
      "total:", cx

  drawSide: (paper, x0, y0, cx, cy) ->
    self = @
    scale = @ostate.scale
    x0 = @ostate.sideview.x0
    y0 = @ostate.sideview.y0
    # draw base, filled with color
    y = y0 + @bay.back_height * scale
    paper.rect(x0, y, @bay.base_depth * scale, @bay.base_height * scale).
      attr("fill", @bay.base_color)
    # draw back
    paper.rect(x0, y0, @bay.back_thick * scale, @bay.back_height * scale).
      attr("fill", @bay.back_color)

    # draw shelves & numbers, filled with color
    for shelf in @bay.open_shelves
      if shelf
        @sideLayerRender.open_shelf.call(self, paper, shelf)
      true
    return true

  sideLayerRender:
    open_shelf: (paper, shelf) ->
      scale = @ostate.scale
      x = @ostate.sideview.x0 + @bay.back_thick * scale
      y = @ostate.sideview.y0 + (@bay.back_height - shelf.from_base) * scale
      cx = shelf.depth * scale
      cy = shelf.thick * scale
      paper.rect(x, y, cx, cy).attr("fill", shelf.color)
      x0 = x + cx / 2
      paper.text(x0, y + cy / 2, shelf.name)
      # draw depth metrics
      y0 = y - cy / 2
      paper.hruler(x, y0, x + cx, 40, 20, "#{shelf.depth}cm")
      # el.attr("stroke", "red")
      return true

  frontLayerRender:
    open_shelf: (paper, shelf) ->
      scale = @ostate.scale
      x = @ostate.frontview.x0
      y = @ostate.frontview.y0 + (@bay.back_height - shelf.from_base) * scale
      cx = shelf.width * scale
      cy = shelf.thick * scale
      paper.rect(x, y, cx, cy).attr("fill", shelf.color)
      paper.text(x + cx / 2, y + cy / 2, "#{shelf.name} #{shelf.width}cm")
      return true

  drawTakeoffHeight: (paper) ->
    scale = @ostate.scale
    x1 = @ostate.frontview.x0
    x2 = x1 + @ostate.width
    y0 = @ostate.sideview.y0
    y = y0 + (@bay.back_height - @bay.takeoff_height) * scale
    paper.path("M#{x1} #{y} L#{x2} #{y}").attr("stroke-dasharray", "- ").attr("stroke", "blue")

  drawNotchNums: (paper) ->
    scale = @ostate.scale
    x0 = @ostate.sideview.x0 - 2
    y0 = @ostate.sideview.y0

    # draw notch ruler at the left side to sideview
    cx = @notch_ruler_width
    x2 = x0 - cx
    x1 = x0 - cx / 2
    # |x2 |x1 |x0
    y0 += @bay.back_height * scale
    h = 0
    i = 0
    while (h <= @bay.back_height)
      y = y0 - h * @ostate.scale
      if (i % 10) == 0
        paper.path("M#{x2} #{y} L#{x0} #{y}")
        paper.text(x2 - 1, y, "#{i}").attr("text-anchor", "end")
      else
        paper.path("M#{x1} #{y} L#{x0} #{y}")
      i += 2
      h = @bay.notch_1st + (i - 1) * @bay.notch_spacing
    return true

  drawFront: (paper, x0, y0, cx, cy) ->
    scale = @ostate.scale
    x0 = @ostate.frontview.x0
    y0 = @ostate.frontview.y0
    # draw back with fill color
    cx = @bay.back_width * scale
    cy = @bay.back_height * scale
    paper.rect(x0, y0, cx, cy).attr("fill", @bay.back_color)

    # draw base with fill color
    cx = @bay.base_width * scale
    cy = @bay.base_height * scale
    paper.rect(x0, y0 + @bay.back_height * scale, cx, cy).attr("fill", @bay.base_color)

    self = @
    for shelf in @bay.open_shelves
      if shelf
        @frontLayerRender.open_shelf.call(self, paper, shelf)
      true
    return true


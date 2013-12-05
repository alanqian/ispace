# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

root = exports ? this

root.test = () ->
  # data = input2json("bay", "form :input:not([type='submit'])")
  root.formHelper ||= new FormDataHelper("form.simple_form.bay")
  return root.formHelper.readInputs()

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
    # for name in ["height", "width", "depth", "thick", "space"]
    #  $("input.numeric.integer[id$='#{name}']").attr("step", 10).attr("min", 0)
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
    @formHelper ||= new FormDataHelper("form.simple_form.bay")
    bay = new Bay(@formHelper.readInputs(), inputName)
    console.log bay
    preview = $("#bay-preview")
    cx = preview.width()
    cy = preview.height()
    paper = Raphael(preview[0], cx, cy)
    bay.draw(paper, cx, cy)
    true


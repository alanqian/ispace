# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

root = exports ? this

root.test = () ->
  data = input2json("bay", "form input:not([type='submit'])")
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
      val = parseFloat($(el).val())
    else if $(el).hasClass("integer")
      val = parseInt($(el).val())
    else if $(el).hasClass("string")
      val = $(el).val()
    else if $(el).attr("type") == "checkbox"
      val = $(el).is(":checked")
    else if $(el).attr("type") == "hidden"
      val = $(el).val()
    else
      console.log "unknown input: ", el
      val = $(el).val()

    #console.log key, tail, val
    if tail == "_destroy"
      if val == "1"  # hidden
        # remove the whole parent branch
        removed[key] = val
        tail = fields.pop()
        v = data
        for field in fields
          if v[field]?
            v = v[field]
          else
            return true
        delete v.splice(tail, 1)
    else
      # initialize the section value to [] if undefined
      v = data
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

class BayPage
  action: ""
  _do: ""
  bay: null

  constructor: (action, _do) ->
    console.log "create PlanPage"
    @action = action
    @_do = _do

  onLoadEdit: () ->
    @loadBayEditor()

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

    # assume first input is element name
    nameElem = $("input", $new).first()
    if nameElem
      new_name = "#{@bay.newIndex}.#{nameElem.attr("placeholder")}"
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

  loadBayEditor: () ->
    console.log "bay editor start loading..."
    $("select.colorpicker").simplecolorpicker
      picker: true
    $("div .elem_inputs").animate({ marginLeft: 10 }, "fast")
    $("div .elem_inputs").css({"background-color":"#88ff88"})

    sortByChildElem = (a, b) ->
      va = parseFloat($(a).find(".elem_sort_by")[0].value) || 0.0
      vb = parseFloat($(b).find(".elem_sort_by")[0].value) || 0.0
      # console.log "sort:", va, vb
      return vb - va
    $("div .elem_inputs").sort(sortByChildElem).children().appendTo("#accordion")

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
      console.log "update notch_num/from_base, use_notch:", $("#bay_use_notch").is(":checked")
      if $("#bay_use_notch").is(":checked")
        # update from_base
        self.bay.notches_to()
      else
        # always let browser send notch_* parameter, and update notch_num as well
        $("#bay_notch_1st, #bay_notch_spacing").prop("disabled", false)
        self.bay.to_notches()
      self.updateElementsLevel()
      # TODO: check notch_nums and from_base of each level
      return true

    # page loaded
    return true

root.BayPage = BayPage


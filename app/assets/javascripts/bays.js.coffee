# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

sortByFromBase = (a, b) ->
  va = parseFloat($(a).find(".elem_from_base")[0].value) || 0.0
  vb = parseFloat($(b).find(".elem_from_base")[0].value) || 0.0
  # console.log "sort:", va, vb
  return vb - va

$ ->
  console.log "bay editor start loading..."
  $("div .elem_inputs").animate({ marginLeft: 10 }, "fast")
  $("div .elem_inputs").css({"background-color":"#88ff88"})

  count = $("div .elem_inputs").length
  $("div .elem_inputs").sort(sortByFromBase).children().appendTo("#accordion")
  $("#accordion").accordion({active: -1, heightStyle: "content" })

  window.bay =
    newIndex: count + 1
    active: count - 1
    use_notch: -> $("#bay_use_notch").is(":checked")
    notch_spacing: -> parseFloat $("#bay_notch_spacing").val()
    notch_1st: -> parseFloat $("#bay_notch_1st").val()

    notch_to: (notch) ->
      (parseInt(notch) - 1) * @notch_spacing() + @notch_1st()

    to_notch: (from_base) ->
      if @notch_spacing() > 0.1
        Math.floor((parseFloat(from_base) - @notch_1st()) / @notch_spacing()) + 1
      else
        ""

  fnRemoveElement = (ev) ->
    # set _destroy to true
    $(this).prev("input[type=hidden]").val("1")

    # move the elements h3+div to dummy
    h3 = $(this).closest("h3")
    h3.next().andSelf().appendTo($("#dummy"))
    $("#accordion").accordion("refresh")
    ev.preventDefault()
    return false

  fnUpdateNotchInputElements = (use_notch) ->
    if use_notch
      $(".elem_notch_num").parent().show()
      $(".elem_from_base").parent().hide()
      $(".elem_from_base").removeAttr("required")
      $("#bay_notch_1st, #bay_notch_spacing").prop("disabled", false)
      $("#bay_notch_1st, #bay_notch_spacing").prev().fadeTo(10, 1)
    else
      $(".elem_from_base").parent().show()
      $(".elem_notch_num").parent().hide()
      $(".elem_notch_num").removeAttr("required")
      $("#bay_notch_1st, #bay_notch_spacing").prop("disabled", true)
      $("#bay_notch_1st, #bay_notch_spacing").prev().fadeTo(10, 0.5)

  fnUpdateNotchInputElements $("#bay_use_notch").is(":checked")
  $(".remove_element").click(fnRemoveElement)

  # move template to outside of the form
  $("form").after($("#template"))

  $(".add_element").click (ev) ->
    console.log "current active element:",
      $("#accordion").accordion("option", "active")

    dataId = $(this).attr "data-id"
    console.log "data-id:", dataId
    console.log "maxElems:", window.bay.maxElems
    tmpl = $(dataId)

    re = new RegExp(tmpl.data("id"), "g")
    fieldId = (window.bay.newIndex + 10).toString()
    console.log re
    console.log "fieldId:", fieldId
    src = $(tmpl).html().replace("\\n", "").replace(re, fieldId)
    # console.log src
    $("#accordion").prepend(src).accordion("destroy").accordion({ heightStyle: "content" })
    $(".remove_element").click(fnRemoveElement)

    # assume first input is element name
    nameElem = $("#accordion h3 input").first()
    nameElem.val(nameElem.val() + window.bay.newIndex) if nameElem

    window.bay.newIndex += 1
    ev.preventDefault()
    return false

  $("#bay_use_notch").change (ev) ->
    console.log "use notch changed!", $(this).is(":checked")
    fnUpdateNotchInputElements $(this).is(":checked")

  $(".elem_from_base").change (ev) ->
    console.log "from_base changed!", $(this).val()
    $(this).parent().prev().children("input").val window.bay.to_notch $(this).val()

  $(".elem_notch_num").change (ev) ->
    console.log "notch_num changed!", $(this).val()
    $(this).parent().next().children("input").val window.bay.notch_to $(this).val()

  console.log "bay editor loaded..."


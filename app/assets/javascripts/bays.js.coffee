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
  $("div .elem_inputs").animate({ marginLeft: 10 }, 'fast')
  $("div .elem_inputs").css({'background-color':'#88ff88'})

  $("div .elem_inputs").sort(sortByFromBase).children().appendTo("#accordion")
  count = $("#accordion h3").length
  $("#accordion").accordion({active: count - 1})
  window.bay = { newIndex: count + 10, active: count - 1 }

  fnRemoveElement = (ev) ->
    # set _destroy to true
    $(this).prev('input[type=hidden]').val('1')

    # move the elements h3+div to dummy
    h3 = $(this).closest('h3');
    h3.next().andSelf().appendTo($('#dummy'))
    $("#accordion").accordion("refresh")
    ev.preventDefault()
    return false

  $(".remove_element").click(fnRemoveElement)

  # move template to outside of the form
  $("form").after($("#template"))

  $(".add_element").click (ev) ->
    curElem = $("#accordion").accordion("option", "active");
    console.log "current active element:", curElem

    dataId = $(this).attr "data-id"
    console.log "data-id:", dataId
    console.log "maxElems:", window.bay.maxElems
    tmpl = $(dataId)

    re = new RegExp(tmpl.data('id'), 'g')
    fieldId = "[" + tmpl.attr('id') + "][" + window.bay.newIndex + "]"
    console.log re
    console.log "fieldId:", fieldId
    newHtml = $(tmpl).html().replace("\\n", "").replace(re, fieldId)
    console.log newHtml
    $("#accordion").prepend(newHtml).accordion("destroy").accordion()

    $(".remove_element").click(fnRemoveElement)

    window.bay.newIndex += 1
    ev.preventDefault()
    return false

  $(".elem_notch_num").change (ev) ->
    console.log "notch_num changed!"
    console.log $(this)

  console.log "bay editor loaded..."


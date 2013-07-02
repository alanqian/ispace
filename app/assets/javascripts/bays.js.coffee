# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

sortByLevel = (a, b) ->
  va = parseInt($(a).find(".elem_level")[0].value)
  vb = parseInt($(b).find(".elem_level")[0].value)
  return vb - va

$ ->
  console.log "bay editor start loading..."
  $("div .elem_inputs").animate({ marginLeft: 10 }, 'fast')
  $("div .elem_inputs").css({'background-color':'#88ff88'})

  $("div .elem_inputs").sort(sortByLevel).children().appendTo("#accordion")
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

  console.log "bay editor loaded..."


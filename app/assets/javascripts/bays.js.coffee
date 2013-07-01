# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

sortByLevel = (a, b) ->
  va = parseInt($(a).find(".elem_level")[0].value)
  vb = parseInt($(b).find(".elem_level")[0].value)
  return vb - va

$ ->
  $("div .elem_inputs").animate({ marginLeft: 10 }, 'fast')
  $("div .elem_inputs").css({'background-color':'#88ff88'})

  $("div .elem_inputs").sort(sortByLevel).children().appendTo("#accordion")
  shelf_1st = $("#accordion h3").length - 1
  $("#accordion").width(500).accordion({active: shelf_1st})


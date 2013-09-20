# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$ ->
  $(".toolbar-button").each (index, el) ->
    btn = $(el).button
      disable: false
      text: false
      label: el.text
      icons:
        primary: $(el).data("icon")
        secondary: $(el).data("icon2")
    btn.click ->
      console.log "click it:", this.id

  sorts = $("ul.sortable-editor").sortable
    connectWith: ".sortable-editor"
    receive: (e, ui)->
      # ui.item.parent() => received ul
      # remove is the constract
      console.log "received:", ui.item, ui.item.parent()
    over: (e, ui) ->
      console.log "over:", ui.item, e.target

  sorts.disableSelection()

  # postion to tr
  $("ul.sortable-editor").each (index, el) ->
    target = $(el).data("container")
    $(el).width $(target).width() - ($(el).outerWidth() - $(el).width())
    $(el).height $(target).height() - ($(el).outerHeight() - $(el).height())
    $(el).position
      my: "left bottom"
      at: "left bottom"
      of: target
      collision: "none"

  # create grid for product
  $("ul.sortable-editor li").each (index,el) ->
    rows = 5
    cols = 6
    # create a rows x cols table in LI
    tds = Array(cols+1).join("<td></td>")
    trs = Array(rows+1).join("<tr>#{tds}</tr>")
    table = "<table><tbody>#{trs}</tbody></table>"
    $(el).html(table)

  # align each LI to bottom of UL
  $("ul.sortable-editor").each (index, ul) ->
    total = $(ul).height()
    $(ul).children("li").each (index, li) ->
      h = $(li).outerHeight()
      $(li).css("margin-top", (total - h) + "px")

    # position it
    # $("#test").position({my: "left top", at: "left top", of: $("#back"), collision: "none"})

  return true
  $("div.ui-resizable").resizable()
  $("div.ui-draggable").draggable()

  #############################################
  # following is test code
  sel = $("#select").button
    disabled: false
    text: false
    label: "v"
    icons:
      primary: "ui-icon-triangle-1-s"

  $(".toolbar-button-set").each (index,el) ->
    $(el).buttonset()

  sel.click ->
    menu = $("#menu").show().position
      my: "left top"
      at: "left bottom"
      of: this
    $(document).one "click", ->
      menu.hide()
    return false

  $("#menu").hide().menu()
  #############################################


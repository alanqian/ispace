# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $("#product-tabs").tabs(
    activate: (event, ui) ->
      console.log "activate:", ui.newPanel.selector
      window.location.hash = ui.newPanel.selector
  )


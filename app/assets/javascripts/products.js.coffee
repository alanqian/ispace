# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('#new_import_sheet').bind('ajax:success', (event, data, status, xhr) ->
    console.log "ajax success new_import_sheet"
    console.log data
  ).bind("ajax:error", (evt, xhr, status, error) ->
    console.log "ajax error"
    console.log status, error
    console.log xhr
  )

  console.log "set ajax ok"

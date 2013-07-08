# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

root = exports ? this

root.test = () ->
  foo()

$ ->
  console.log "fixture editor start..."
  console.log window.bays[30]

root.addFixtureItem = (event, el) ->
  console.log "add fixture item"
  event.preventDefault()

root.removeFixtureItem = (event, el) ->
  console.log "remove fixture item"
  event.preventDefault()

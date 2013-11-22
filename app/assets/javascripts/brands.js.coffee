# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#
root = exports ? this

root.onSelectCategory = (el) ->
  name = $(el).text()
  input = $("#brand_category_name")
  input.val(name)
  id = $(el).data("id")
  if id
    window.location = $(input).data("url") + id
  return true

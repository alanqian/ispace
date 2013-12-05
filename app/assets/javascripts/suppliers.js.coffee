# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
root = exports ? this

root.SupplierPage = class SupplierPage
  onCategoryChanged: (el) ->
    id = $(el).val()
    url = $(el).data("url")
    # only for index page, the input element has data url
    if url && id
      window.location = url + id
    return true


# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

root = exports ? this

root.onSetRefStoreId = (el) ->
  if $("input:checked[name='stores[]']").length == 0
    alert "请先选中要设置的门店，再进行设置"
  else
    store_id = $(el).data("id")
    $("input[name='store[ref_store_id]']").val(store_id)
    $("form#set-model-stores-form").submit()
  return true

class StorePage
  action: ""
  _do: ""

  constructor: (action, _do) ->
    console.log "create StorePage"
    @action = action
    @_do = _do

  onLoadIndex: () ->
    $("#setup-model-store").click (e) ->
      e.stopPropagation()
      $.util.popupMenu "#select-model-store",
        under: this
    # $("#plan-layout-form").submit()
    console.log "stores inited"
    return true

root.StorePage = StorePage

$ ->
  $.util.onPageLoad()


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

root.onSelectStoreFixtureCategory = (el) ->
  category_id = $(el).data("id")
  category_name = $(el).text()
  src = "#" + $(el).data("src-element")
  # category id element
  el = $(src).prev("input[type=hidden].category_id")

  # set category_id/category_name
  $(src).val(category_name)
  $(el).val(category_id)

  # set category_mid
  dict = $("#category_dict").data("dict")
  parent_id = dict[category_id].parent_id
  tr = $(src).closest("tr")
  span = $("td:first>span.category_mid", tr)
  console.log "update category", span, parent_id, category_id
  if parent_id != span.data("id").toString()
    upper = dict[parent_id]
    span.text(upper.name)
    span.data("id", parent_id)

    # update show/hide of this row
    span_0 = $("td:first>span.category_mid", tr.prevAll("tr").first())
    prev_id = span_0.data("id").toString() if span_0.length > 0
    console.log "prev", span_0, prev_id
    if parent_id != prev_id
      span.removeClass("hide")
    else
      span.addClass("hide")

    # update next row if necessary
    span_2 = $("td:first>span.category_mid", tr.nextAll("tr").first())
    if span_2.length > 0
      next_id = span_2.data("id").toString()
      console.log "next", span_2, prev_id
      if parent_id != next_id
        span_2.removeClass("hide")
      else
        span_2.addClass("hide")
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

  onLoadUpdate: () ->


  onLoadEditFixture: () ->

root.StorePage = StorePage

$ ->
  $.util.onPageLoad()


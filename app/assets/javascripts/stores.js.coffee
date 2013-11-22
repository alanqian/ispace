# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

root = exports ? this

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
    @new_sf_index = $("input[type=hidden][name$='[_destroy]']").length + 100

    #$("a#delete_store_fixture").click (e) ->
    #  root.removeStoreFixture(e, this)
    #  return false

    #$("a#add_store_fixture").click (e) ->
    #  root.addStoreFixture(e, this)
    #  return false

  onSetRefStoreId: (el) ->
    if $("input:checked[name='stores[]']").length == 0
      alert "请先选中要设置的门店，再进行设置"
    else
      store_id = $(el).data("id")
      $("input[name='store[ref_store_id]']").val(store_id)
      $("form#set-model-stores-form").submit()
    return true

  onSelectStoreFixtureCategory: (el) ->
    category_id = $(el).data("id")
    category_name = $(el).text()
    src = "#" + $(el).data("src-element")
    tr = $(src).closest("tr")
    @updateCategory(tr, category_id, category_name)

  onRemoveStoreFixture: (el) ->
    console.log "removeStoreFixture", el
    # set _destroy to true
    $(el).siblings("input[type=hidden][name$='[_destroy]']").val("1")

    # update span.visiblity of next row
    tr = $(el).closest("tr")
    span = $("td:first>span.category_mid", tr)
    visible = !span.hasClass("hide")
    next_tr = tr.nextAll("tr").first()
    if visible && next_tr.length > 0
      # visible next row
      span = $("td:first>span.category_mid", next_tr)
      span.removeClass("hide")

    # move to deleted area
    tr.appendTo($("tbody#deleted"))
    return true

  onAddStoreFixture: (el) ->
    console.log "addStoreFixture", el
    tr = $(el).closest("tr")
    if $("tbody#store_fixture_list tr").length == 0
      # @onAddStoreFixtureAll(tr)
      @createStoreFixtureRow(tr)
    else
      @createStoreFixtureRow(tr)
    return true

  onAddStoreFixtureAll: (tr) ->
    $("body").css("cursor", "progress")
    nodes = @getCategoryLeafNodes()
    for id, node of nodes
      tr = @createStoreFixtureRow(tr)
      @updateCategory(tr, id, node.name)
    $("body").css("cursor", "auto")
    return true

  getCategoryDict: () ->
    $("#category_dict").data("dict")

  getCategoryLeafNodes: () ->
    dict = $("#category_dict").data("dict")
    leaves = {}
    for k, v of dict
      if v.parent_id != null
        leaves[k] = v
        delete leaves[v.parent_id]
    return leaves

  createStoreFixtureRow: (tr) ->
    new_index = @new_sf_index.toString()
    new_id = "new_store_fixture_#{new_index}"
    @new_sf_index++
    # replace new_sf_index
    re = new RegExp("new_sf_index", "g")
    src = $("#template tbody").html().replace("\\n", "").replace(re, new_index)

    # add to new table, after the click tr
    if tr.parent("tbody").length == 0 ## at thead
      tbody = tr.parent().next()
      new_tr = $(src).prependTo(tbody).attr("id", new_id)
    else
      new_tr = $(src).insertAfter(tr).attr("id", new_id)

    # initialize js
    $.util.init("cmd-ui:anchor", new_tr) # for remove anchor
    $.util.init("ui-tree-input", new_tr) # "##{new_id} input.category-name")
    $.util.init("ui-group-checkbox", new_tr) #setupUIGroupCheckbox("##{new_id} input.ui-group-checkbox")
    new_tr

  updateCategory: (tr, category_id, category_name) ->
    # set category_id/category_name
    $("input[name$='[category_id]']", tr).val(category_id)
    $("input[name$='[category_name]']", tr).val(category_name)

    # set category_mid
    dict = @getCategoryDict()
    parent_id = dict[category_id].parent_id
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

root.StorePage = StorePage

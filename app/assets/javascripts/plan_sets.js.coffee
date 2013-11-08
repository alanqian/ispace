root = exports ? this

root.onSelectCategory = (el) ->
  id = $(el).data("id")
  name = $(el).text()
  $("#plan_set_category_name").val(name)
  $("#plan_set_category_id").val(id)
  return true

class PlanSetPage
  action: ""
  _do: ""

  constructor: (action, _do) ->
    console.log "create PlanSetPage"
    @action = action
    @_do = _do

  onLoadIndex: () ->

  onLoadEdit: () ->
    # todo: Add store info when click

  testTree: () ->
    if $("#plan_set_category_name").length > 0
      data = $.util.createTreeData $("#plan_set_category_name").data("source"),
        id: "code"
        parent: "parent_id"
        label: "name"
        rootId: null
      # console.log data
      # test jqtree view
      if $("#tree1").length > 0
        $("#tree1").tree
          data: data
          useContextMenu: false
          autoOpen: true

        $('#tree1').bind "tree.click", (e) ->
          console.log "click", e.node

root.PlanSetPage = PlanSetPage

$ ->
  $.util.onPageLoad()

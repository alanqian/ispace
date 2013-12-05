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

  onLoadEditPublish: () ->
    true

  onLoadEdit: () ->
    el = "#model-store-info"
    stores_info = $(el).data("stores")
    console.log stores_info
    $("form.edit_plan_set div.plan_set_model_stores span.checkbox input.check_boxes").click (e) ->
      store_id = $(this).val()
      store = stores_info[store_id]
      store["name"] = $(this).next("label").text()
      for k,v of store
        console.log k,v
        $("span#store_#{k}", el).text(v)
      $(el).css("visibility", "visible")
      true
    @init_category_hint()
    true

  init_category_hint: () ->
    if $("input#plan_set_category_name").is(":disabled")
      $("input#plan_set_category_name").next("span.hint").show()

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

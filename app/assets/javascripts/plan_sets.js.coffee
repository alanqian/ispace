root = exports ? this

root.onSelectCategory = (el) ->
  id = $(el).data("id")
  name = $(el).text()
  $("#plan_set_category_name").val(name)
  $("#plan_set_category_id").val(id)
  return true

$ ->
  # test menu select category
  if $("#plan_set_category_name").length > 0
    menu = root.cmdUI.createMenu "select-category", $("#plan_set_category_name").data("source"),
      id: "code"
      parent: "parent_id"
      label: "name"
      rootId: null
      dom: "#test-menu"
    root.cmdUI.popupMenuSelect menu,
      right: "#plan_set_category_name"

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


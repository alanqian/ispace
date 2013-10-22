root = exports ? this

root.onSelectCategory = (el) ->
  id = $(el).data("id")
  name = $(el).text()
  $("#plan_set_category_name").val(name)
  $("#plan_set_category_id").val(id)
  return true

$ ->
  # test menu select category
  if $("plan_set_category_name").length > 0
    menu = root.cmdUI.createMenu "select-category", $("#plan_set_category_name").data("source"),
      id: "code"
      parent: "parent_id"
      label: "name"
      rootId: null
      dom: "#test-menu"
    root.cmdUI.popupMenuSelect menu,
      right: "#plan_set_category_name"

  # test jqtree view
  if $("#tree1").length > 0
    data = [
      label: 'Saurischia'
      id: 1
      test: 22
      children: [
        label: 'abc'
       ,
        label: 'abc'
      ]
     ,
      label: 'Ornithischians'
      id: 23
      test: "aa"
    ]
    $("#tree1").tree
      data: data
      useContextMenu: false

    $('#tree1').bind "tree.click", (e) ->
      console.log "click", e

